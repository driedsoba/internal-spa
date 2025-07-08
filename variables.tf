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
