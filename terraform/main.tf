terraform {
  backend "s3" {
  encrypt = true
  }
}

resource "aws_vpc" "new_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "new-VPC"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-333"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}