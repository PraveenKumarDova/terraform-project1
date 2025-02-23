terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
  # backend "s3" {
  #   bucket = "tfstate-bkt1"
  #   key = "terraform.tfstate"
  #   region = "eu-west-2"
  #   dynamodb_table = "aws-table"
  # }
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

//VPC

resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myVPC"
  }
}

//subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "subnet1"
  }
}

//Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "igw"
  }
}

//Route table
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt1"
  }

}

//5)Route Table association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id

}

//6.Secutiy group creation

resource "aws_security_group" "mywebsecurity" {
  name        = "ownsecurityrules"
  description = "allow TLS inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    name = "mySG"
  }

}

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.myami.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.mywebsecurity.id]
  key_name                    = "london1"
  user_data                   = file("server-script.sh")

  tags = {
    Name = "web_server"
  }

}

output "public_ip" {
  value = aws_instance.web_server.public_ip

}

output "ami" {
  value = aws_instance.web_server.ami

}

output "instance_id" {
  value = aws_instance.web_server.id

}

output "instance_type" {
  value = aws_instance.web_server.instance_type

}

