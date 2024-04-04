provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "deploymentID" {
  type        = string
  description = "Deployment ID for the ELB"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "DefaultVPC"
  }
}

resource "aws_subnet" "default_subnet_1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "DefaultSubnet1"
  }
}

resource "aws_subnet" "default_subnet_2" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "DefaultSubnet2"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "DefaultInternetGateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_security_group" "elb" {
  name        = "elb-security-group"
  vpc_id      = aws_vpc.default.id
  
  # Define security group rules as needed
}

resource "aws_elb" "example" {
  name            = "example-elb"
  availability_zones = ["us-east-1a", "us-east-1b"]
  security_groups = [aws_security_group.elb.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    deploymentID = "${var.deploymentID}"
    Environment  = "Production"
  }
}

resource "aws_security_group_rule" "elb_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = aws_security_group.elb.id
}
