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

data "aws_security_group" "wordpress-web-sg" {
  filter {
    name    = "tag:Name"
    values  = ["wordpress-web-sg"]
  }
}

data "aws_subnet" "private-1a" {
  filter {
    name    = "tag:Name"
    values  = ["private-1a"]
  }
}

data "aws_subnet" "private-1c" {
  filter {
    name    = "tag:Name"
    values  = ["private-1c"]
  }
}

resource "aws_security_group" "wordpress-rds-sg" {
  name        = "wordpress-rds-sg"
  vpc_id      = data.aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  security_group_id = aws_security_group.wordpress-rds-sg.id
  from_port                     = 3306
  ip_protocol                   = "tcp"
  to_port                       = 3306
  referenced_security_group_id  = data.aws_security_group.wordpress-web-sg.id 
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress-rds-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_subnet_group" "wordpress-rds-subnet-group" {
  name              = "wordpress-rds-subnet-group"
  subnet_ids        = [data.aws_subnet.private-1a.id,data.aws_subnet.private-1c.id]

  tags = {
    Name = "wordpress-rds-subnet-group"
  }
}
