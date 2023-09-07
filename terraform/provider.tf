terraform {
  backend "s3" {
    bucket         = "my-unique-bucket-name-333"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}