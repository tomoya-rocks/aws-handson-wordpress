terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region    = "ap-northeast-1"
}

data "aws_vpc" "wordpress-vpc" {
  filter {
    name    = "tag:Name"
    values  = ["wordpress-vpc"]
  }
}

data "aws_subnet" "public-1a" {
  filter {
    name    = "tag:Name"
    values  = ["public-1a"]
  }
}

data "aws_subnet" "public-1c" {
  filter {
    name    = "tag:Name"
    values  = ["public-1c"]
  }
}

data "aws_ami" "wordpress-ami" {
  filter {
    name    = "name"
    values  = ["almalinux9-wordpress"]
  }
}

resource "aws_security_group" "wordpress-web-sg" {
  name        = "wordpress-web-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.wordpress-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.wordpress-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "wordpress-1a" {
  ami                           = data.aws_ami.wordpress-ami.id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  availability_zone             = "ap-northeast-1a"
  subnet_id                     = data.aws_subnet.public-1a.id
  key_name                      = "ec2-key"
  vpc_security_group_ids        = [aws_security_group.wordpress-web-sg.id]
  tags = {
    Name = "wordpress-1a"
  }
}

resource "aws_instance" "wordpress-1c" {
  ami                           = data.aws_ami.wordpress-ami.id
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  availability_zone             = "ap-northeast-1c"
  subnet_id                     = data.aws_subnet.public-1c.id
  key_name                      = "ec2-key"
  vpc_security_group_ids        = [aws_security_group.wordpress-web-sg.id]
  tags = {
    Name = "wordpress-1c"
  }
}
