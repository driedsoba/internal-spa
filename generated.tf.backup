# Create lambda-packages directory for zip files
resource "null_resource" "create_lambda_packages_dir" {
  provisioner "local-exec" {
    command = "mkdir -p lambda-packages"
  }
}

# Lambda Function Packaging
data "archive_file" "direct_s3_upload_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/DirectS3Upload.js"
  output_path = "${path.module}/lambda-packages/DirectS3Upload.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "admin_file_manager_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/AdminFileManager.mjs"
  output_path = "${path.module}/lambda-packages/AdminFileManager.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "bucket_administrator_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/BucketAdministrator.mjs"
  output_path = "${path.module}/lambda-packages/BucketAdministrator.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "list_s3_buckets_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/ListS3Buckets.mjs"
  output_path = "${path.module}/lambda-packages/ListS3Buckets.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

# API Gateway
resource "aws_api_gateway_rest_api" "spa_api" {
  name        = "spa-upload-api"
  description = "API for SPA file upload system"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {}
}

# IAM Roles
resource "aws_iam_role" "lambda_adminfilemanager_role" {
  name = "AdminFileManager-role-8e5nfd3s"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {}
}

resource "aws_iam_role" "lambda_bucketadministrator_role" {
  name = "BucketAdministrator-role-pnbrbddo"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {}
}

resource "aws_iam_role" "lambda_directs3upload_role" {
  name = "DirectS3Upload-role-zviwdm3v"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {}
}

resource "aws_iam_role" "lambda_lists3buckets_role" {
  name = "ListS3Buckets-role-upaksby2"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {}
}

# Lambda Functions
resource "aws_lambda_function" "admin_file_manager" {
  filename         = data.archive_file.admin_file_manager_zip.output_path
  function_name    = "AdminFileManager"
  handler          = "index.handler"
  memory_size      = 128
  role             = aws_iam_role.lambda_adminfilemanager_role.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.admin_file_manager_zip.output_base64sha256
  timeout          = 3

  tags = {}
}

resource "aws_lambda_function" "bucket_administrator" {
  filename         = data.archive_file.bucket_administrator_zip.output_path
  function_name    = "BucketAdministrator"
  handler          = "index.handler"
  memory_size      = 128
  role             = aws_iam_role.lambda_bucketadministrator_role.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.bucket_administrator_zip.output_base64sha256
  timeout          = 3

  tags = {}
}

resource "aws_lambda_function" "direct_s3_upload" {
  filename         = data.archive_file.direct_s3_upload_zip.output_path
  function_name    = "DirectS3Upload"
  handler          = "index.handler"
  memory_size      = 128
  role             = aws_iam_role.lambda_directs3upload_role.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.direct_s3_upload_zip.output_base64sha256
  timeout          = 3

  tags = {}
}

resource "aws_lambda_function" "list_s3_buckets" {
  filename         = data.archive_file.list_s3_buckets_zip.output_path
  function_name    = "ListS3Buckets"
  handler          = "index.handler"
  memory_size      = 128
  role             = aws_iam_role.lambda_lists3buckets_role.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.list_s3_buckets_zip.output_base64sha256
  timeout          = 3

  tags = {}
}

# ALB
resource "aws_lb" "spa_alb" {
  name               = "spa-internal-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  # Use ONLY subnets, removed conflicting subnet_mapping
  subnets = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]

  enable_deletion_protection = false

  tags = {}
}

# Target Group - Fixed missing required arguments
resource "aws_lb_target_group" "lb_target_group" {
  name        = "s3-spa-target-public"
  port        = 443
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,307,405,301"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTPS"
    timeout             = 10
    unhealthy_threshold = 2
  }

  # Removed problematic target_failover and target_health_state blocks
  # that had null required values

  tags = {}
}

# S3 Bucket
resource "aws_s3_bucket" "spa_bucket" {
  bucket = "spa.chatwithjunle.com"
  tags   = {}
}

# Security Groups - Using references instead of hard-coded IDs
resource "aws_security_group" "alb_sg" {
  name        = "spa-public-alb-sg"
  description = "Allow inbound traffic from my own laptop"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from my own laptop"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["118.189.14.110/32"]
  }

  egress {
    description     = "Allow outbound traffic to s3 interface endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.s3_interface_sg.id]
  }

  tags = {}
}

resource "aws_security_group" "s3_interface_sg" {
  name        = "s3-interface-endpoint-sg"
  description = "Security group for S3 Interface Endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["sg-0fdcb91c73d323b2c"] # External SG reference
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {}
}

# Subnets - Fixed all conflicting parameters
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-1a"


  tags = {
    Name = "project-subnet-private1-ap-southeast-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-1c"
  # Fixed same issues as private_1a

  tags = {
    Name = "project-subnet-private1-ap-southeast-1c"
  }
}

# VPC 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "project-vpc"
  }
}

# VPC Endpoint - S3 Interface Endpoint
resource "aws_vpc_endpoint" "s3_interface" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-southeast-1.s3"
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
    Name = "s3-interface-endpoint"
  }
}
