variable "aws_region" {
  description = "The AWS region where the infrastructure will be deployed."
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet."
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet."
}

variable "public_instance_ami" {
  description = "The AMI ID for the public EC2 instance."
}

variable "private_instance_ami" {
  description = "The AMI ID for the private EC2 instance."
}