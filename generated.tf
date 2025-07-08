# IMPORT-ONLY CONFIGURATION
# This will import existing AWS resources into Terraform Cloud state
# After imports succeed, replace with full generated.tf

# S3 Bucket - minimal for import
resource "aws_s3_bucket" "spa_bucket" {
  bucket = "spa.chatwithjunle.com"
}

# VPC - minimal for import  
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Subnets - minimal for import
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-southeast-1a"
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-southeast-1c"
}

# Security Groups - minimal for import
resource "aws_security_group" "alb_sg" {
  name_prefix = "spa-public-alb-sg"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "s3_interface_sg" {
  name_prefix = "s3-interface-endpoint-sg"
  vpc_id      = aws_vpc.main.id
}

# IAM Roles - minimal for import
resource "aws_iam_role" "lambda_directs3upload_role" {
  name = "DirectS3Upload-role-zviwdm3v"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "lambda_adminfilemanager_role" {
  name = "AdminFileManager-role-8e5nfd3s"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "lambda_bucketadministrator_role" {
  name = "BucketAdministrator-role-pnbrbddo"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "lambda_lists3buckets_role" {
  name = "ListS3Buckets-role-upaksby2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Lambda Functions - minimal for import
resource "aws_lambda_function" "direct_s3_upload" {
  function_name = "DirectS3Upload"
  role          = aws_iam_role.lambda_directs3upload_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "dummy.zip" # Will be updated after import

  lifecycle {
    ignore_changes = [filename, source_code_hash, last_modified]
  }
}

resource "aws_lambda_function" "admin_file_manager" {
  function_name = "AdminFileManager"
  role          = aws_iam_role.lambda_adminfilemanager_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "dummy.zip" # Will be updated after import

  lifecycle {
    ignore_changes = [filename, source_code_hash, last_modified]
  }
}

resource "aws_lambda_function" "bucket_administrator" {
  function_name = "BucketAdministrator"
  role          = aws_iam_role.lambda_bucketadministrator_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "dummy.zip" # Will be updated after import

  lifecycle {
    ignore_changes = [filename, source_code_hash, last_modified]
  }
}

resource "aws_lambda_function" "list_s3_buckets" {
  function_name = "ListS3Buckets"
  role          = aws_iam_role.lambda_lists3buckets_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  filename      = "dummy.zip" # Will be updated after import

  lifecycle {
    ignore_changes = [filename, source_code_hash, last_modified]
  }
}

# API Gateway - minimal for import
resource "aws_api_gateway_rest_api" "spa_api" {
  name = "spa-upload-api"
}

# ALB - minimal for import
resource "aws_lb" "public_alb" {
  name               = "spa-internal-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
}

# Target Group - minimal for import
resource "aws_lb_target_group" "lb_target_group" {
  name     = "s3-spa-target-public"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
}

# VPC Endpoint - minimal for import
resource "aws_vpc_endpoint" "s3_interface" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  security_group_ids = [aws_security_group.s3_interface_sg.id]
}
