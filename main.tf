terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  # access_key = "access_key"
  # secret_key = "secret_key"
}

# resource "aws_instance" "app_server" {
#   # count         = 2
#   ami           = "ami-0076be86944570bff"
#   instance_type = "t2.micro"

#   tags = {
#     # Name = "app_server-${count.index}"
#     name = "app_server"
#   }
# }

variable "instance_type" {

}

data "aws_ami" "myami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]

}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.myami.id
  instance_type = var.instance_type

  tags = {
    Name = "app_server"
  }

}

output "public_ip" {
  value = aws_instance.app_server.public_ip

}

output "ami" {
  value = aws_instance.app_server.ami

}

output "instance_id" {
  value = aws_instance.app_server.id

}

output "instance_type" {
  value = aws_instance.app_server.instance_type

}