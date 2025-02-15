terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  # access_key = "access_key"
  # secret_key = "secret_key"
}