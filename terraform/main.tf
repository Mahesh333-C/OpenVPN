resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Generate a key-pair with above key
resource "aws_key_pair" "deployer" {
  key_name   = "mykeypair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "aws_security_group" "public_instance_sg" {
  name_prefix = "public-instance-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "UDP 1194"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "private_instance_sg" {
  name_prefix = "private-instance-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "UDP 1194"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main.id
}

resource "local_file" "private_key_file" {
  filename = "mykeypair.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_instance" "public_instance" {
  ami           = var.public_instance_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/Mahesh333-C/OpenVPN.git",
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible", 
      "sudo apt install -y ansible",
      "echo '${tls_private_key.key_pair.private_key_pem}' > ~/mykeypair.pem",
      "chmod 600 ~/mykeypair.pem",
      "ansible-playbook -i localhost, OpenVPN/openVPNConfig.yml", 
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu" 
      private_key = tls_private_key.key_pair.private_key_pem 
    }
  }

  tags = {
    Name = "PublicInstance"
  }
}

resource "aws_instance" "private_instance" {
  ami           = var.private_instance_ami
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]

  tags = {
    Name = "PrivateInstance"
  }
}