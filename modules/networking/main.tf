# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.project_name}-vpc"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# Private Subnets
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_1a_cidr
  availability_zone = var.availability_zone_1a

  tags = {
    Name      = "${var.project_name}-subnet-private1-${var.availability_zone_1a}"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_1c_cidr
  availability_zone = var.availability_zone_1c

  tags = {
    Name      = "${var.project_name}-subnet-private1-${var.availability_zone_1c}"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}


# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "spa-public-alb-sg"
  description = "Allow inbound traffic from my own laptop"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from my own laptop"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description     = "Allow outbound traffic to s3 interface endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.s3_interface_sg.id]
  }

  tags = {
    Name      = "${var.project_name}-alb-sg"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}


# Security Group for S3 Interface Endpoint
resource "aws_security_group" "s3_interface_sg" {
  name        = "s3-interface-endpoint-sg"
  description = "Security group for S3 Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.external_sg_id != null ? [var.external_sg_id] : null
    cidr_blocks     = var.external_sg_id == null ? var.allowed_cidr_blocks : null
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-s3-interface-sg"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# VPC Endpoint - S3 Interface
resource "aws_vpc_endpoint" "s3_interface" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids  = [aws_security_group.s3_interface_sg.id]
  private_dns_enabled = true

  policy = jsonencode({
    Statement = [{
      Action    = "*"
      Effect    = "Allow"
      Principal = "*"
      Resource  = "*"
    }]
  })

  tags = {
    Name      = "${var.project_name}-s3-interface-endpoint"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}
