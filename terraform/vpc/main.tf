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

resource "aws_vpc" "wordpress-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "wordpress-vpc"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "public-1a"
  }
}

resource "aws_subnet" "public-1c" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "public-1c"
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "private-1a"
  }
}

resource "aws_subnet" "private-1c" {
  vpc_id     = aws_vpc.wordpress-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "private-1c"
  }
}

resource "aws_internet_gateway" "wordpress-igw" {
  vpc_id = aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-igw"
  }
}

resource "aws_route_table" "wordpress-route-table" {
  vpc_id = aws_vpc.wordpress-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress-igw.id
  }

  tags = {
    Name = "wordpress-route-table"
  }
}

resource "aws_route_table_association" "public-1a-association" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.wordpress-route-table.id
}

resource "aws_route_table_association" "public-1c-association" {
  subnet_id      = aws_subnet.public-1c.id
  route_table_id = aws_route_table.wordpress-route-table.id
}