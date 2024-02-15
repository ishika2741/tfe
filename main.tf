provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "deploymentID" {
  type    = string
  description = "Deployment ID for the ELB"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "default_subnet_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "default_subnet_2" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  vpc_id      = aws_vpc.default.id

  # Define security group rules as needed
}

resource "aws_alb" "example" {
  name            =  var.lbName
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.default_subnet_1.id, aws_subnet.default_subnet_2.id]

  lifecycle {
    create_before_destroy = true
  }
    tags = {

    deploymentID         = var.deploymentID

    Environment = "Production"

  }
}

/*resource "aws_alb_listener" "example_listener" {
  load_balancer_arn = aws_alb.example.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type    = "text/plain"
      message_body    = "OK"
      status_code     = "200"
    }
  }
  tags = {

    deploymentID         = "${var.deploymentID}"

    Environment = "Production"

  }
}*/
