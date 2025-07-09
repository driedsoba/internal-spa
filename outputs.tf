# Networking outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = module.networking.subnet_ids
}

# Storage outputs
output "bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.bucket_id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.storage.bucket_arn
}

# API Gateway outputs
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "https://${module.api_gateway.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com/prod"
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_gateway_id
}

# Load Balancer outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = module.load_balancer.alb_zone_id
}

# Lambda function outputs
output "lambda_functions" {
  description = "Lambda function ARNs"
  value = {
    admin_file_manager   = module.compute.admin_file_manager_arn
    bucket_administrator = module.compute.bucket_administrator_arn
    direct_s3_upload     = module.compute.direct_s3_upload_arn
    list_s3_buckets      = module.compute.list_s3_buckets_arn
  }
}
