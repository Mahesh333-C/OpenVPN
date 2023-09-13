terraform {
  backend "s3" {
    bucket         = "my-unique-bucket-333"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}