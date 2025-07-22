variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spa"
}

variable "api_description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "API for SPA file upload system"
}

variable "endpoint_type" {
  description = "Endpoint type for API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "direct_s3_upload_lambda_invoke_arn" {
  description = "Invoke ARN for the DirectS3Upload Lambda function"
  type        = string
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
}

variable "admin_file_manager_lambda_invoke_arn" {
  description = "Invoke ARN for the AdminFileManager Lambda function"
  type        = string
}

variable "list_s3_buckets_lambda_invoke_arn" {
  description = "Invoke ARN for the ListS3Buckets Lambda function"
  type        = string
}

variable "bucket_administrator_lambda_invoke_arn" {
  description = "Invoke ARN for the BucketAdministrator Lambda function"
  type        = string
}
