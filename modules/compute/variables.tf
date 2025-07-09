variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spa"
}

variable "lambda_source_dir" {
  description = "Directory containing Lambda source files"
  type        = string
  default     = "./lambda"
}

variable "lambda_packages_dir" {
  description = "Directory for Lambda package zip files"
  type        = string
  default     = "./lambda-packages"
}

variable "create_dir_command" {
  description = "Command to create the lambda packages directory"
  type        = string
  default     = "if not exist lambda-packages mkdir lambda-packages" # Windows PowerShell compatible
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions"
  type        = number
  default     = 128
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "nodejs22.x"
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions"
  type        = number
  default     = 3
}
