terraform {
  required_version = ">= 1.12.0"
  cloud {
    organization = "spa-s3fileupload"
    workspaces {
      name = "internal-spa"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "internal-spa"
      ManagedBy = "terraform"
    }
  }
}


# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  aws_region           = var.aws_region
  vpc_cidr             = "10.0.0.0/16"
  subnet_1a_cidr       = "10.0.128.0/20"
  subnet_1c_cidr       = "10.0.16.0/20"
  availability_zone_1a = "ap-southeast-1a"
  availability_zone_1c = "ap-southeast-1c"
  allowed_cidr_blocks  = var.allowed_cidr_blocks
  external_sg_id       = var.external_sg_id != "" ? var.external_sg_id : null
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name    = var.project_name
  bucket_name     = var.domain_name
  vpc_endpoint_id = module.networking.s3_vpc_endpoint_id
}

# Compute Module (Lambda Functions)
module "compute" {
  source = "./modules/compute"

  project_name        = var.project_name
  lambda_source_dir   = "${path.module}/lambda"
  lambda_packages_dir = "${path.module}/lambda-packages"
  create_dir_command  = "if not exist lambda-packages mkdir lambda-packages"
  lambda_handler      = "index.handler"
  lambda_memory_size  = 128
  lambda_runtime      = "nodejs22.x"
  lambda_timeout      = 3
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name                              = var.project_name
  api_description                           = "API for SPA file upload system"
  endpoint_type                             = "REGIONAL"
  direct_s3_upload_lambda_invoke_arn        = module.compute.direct_s3_upload_invoke_arn
  admin_file_manager_lambda_invoke_arn      = module.compute.admin_file_manager_invoke_arn
  list_s3_buckets_lambda_invoke_arn         = module.compute.list_s3_buckets_invoke_arn
  bucket_administrator_lambda_invoke_arn    = module.compute.bucket_administrator_invoke_arn
  direct_s3_upload_lambda_function_name     = module.compute.direct_s3_upload_name
  admin_file_manager_lambda_function_name   = module.compute.admin_file_manager_name
  list_s3_buckets_lambda_function_name      = module.compute.list_s3_buckets_name
  bucket_administrator_lambda_function_name = module.compute.bucket_administrator_name
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"

  project_name                     = var.project_name
  internal                         = false
  alb_security_group_id            = module.networking.alb_security_group_id
  subnet_ids                       = module.networking.subnet_ids
  enable_deletion_protection       = false
  vpc_id                           = module.networking.vpc_id
  target_group_port                = 443
  target_group_protocol            = "HTTPS"
  target_type                      = "ip"
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_interval            = 30
  health_check_matcher             = "200,307,405,301"
  health_check_path                = "/"
  health_check_timeout             = 10
  health_check_unhealthy_threshold = 2
  ssl_certificate_arn              = var.ssl_certificate_arn
}
