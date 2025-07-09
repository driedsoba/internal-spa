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
