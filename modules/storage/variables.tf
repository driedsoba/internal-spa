variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spa"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "VPC Endpoint ID for S3 access restriction"
  type        = string
}