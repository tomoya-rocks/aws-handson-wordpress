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

data "aws_instance" "wordpress-1a" {
  filter {
    name    = "tag:Name"
    values  = ["wordpress-1a"]
  }
}

data "aws_instance" "wordpress-1c" {
  filter {
    name    = "tag:Name"
    values  = ["wordpress-1c"]
  }
}

resource "aws_security_group" "wordpress-elb-sg" {
  name        = "wordpress-web-elb"
  vpc_id      = data.aws_vpc.wordpress-vpc.id

  tags = {
    Name = "wordpress-web-elb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.wordpress-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.wordpress-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb_target_group" "wordpress-elb-target-group" {
  name              = "wordpress-elb-target-group"
  target_type       = "instance"
  protocol          = "HTTP"
  port              = 80
  vpc_id            = data.aws_vpc.wordpress-vpc.id
  protocol_version  = "HTTP1"
  health_check {
    protocol        = "HTTP"
    path            = "/wp-includes/images/blank.gif"
  }
}

resource "aws_lb_target_group_attachment" "wordpress-elb-target-1a" {
  target_group_arn  = aws_lb_target_group.wordpress-elb-target-group.arn
  target_id         = data.aws_instance.wordpress-1a.id
  port              = 80
}

resource "aws_lb_target_group_attachment" "wordpress-elb-target-1c" {
  target_group_arn  = aws_lb_target_group.wordpress-elb-target-group.arn
  target_id         = data.aws_instance.wordpress-1c.id
  port              = 80
}

resource "aws_lb" "wordpress-elb" {
  name                  = "wordpress-elb"
  internal              = false
  load_balancer_type    = "application"
  ip_address_type       = "ipv4"
  subnets               = [data.aws_subnet.public-1a.id,data.aws_subnet.public-1c.id]
  security_groups       = [aws_security_group.wordpress-elb-sg.id]
}

resource "aws_lb_listener" "wordpress-elb_listener" {
  load_balancer_arn     = aws_lb.wordpress-elb.arn
  port                  = 80
  protocol              = "HTTP"
  default_action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.wordpress-elb-target-group.arn
  }
}