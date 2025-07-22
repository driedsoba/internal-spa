variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "spa.chatwithjunle.com"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "internal-spa"
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Default to open access
}

variable "external_sg_id" {
  description = "External security group ID to reference (optional)"
  type        = string
  default     = "" # Empty means create new security group
}

variable "terraform_cloud_organization" {
  description = "Terraform Cloud organization name"
  type        = string
  default     = ""
}

variable "terraform_cloud_workspace" {
  description = "Terraform Cloud workspace name"
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = "arn:aws:acm:ap-southeast-1:412973596844:certificate/46d4048e-15d3-4135-b377-e11954ab2535"
}
