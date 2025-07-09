variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spa"
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 443
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTPS"
}

variable "target_type" {
  description = "Target type for the target group"
  type        = string
  default     = "ip"
}

variable "health_check_enabled" {
  description = "Enable health check"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for health check"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Interval for health check"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "Matcher for health check"
  type        = string
  default     = "200,307,405,301"
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_timeout" {
  description = "Timeout for health check"
  type        = number
  default     = 10
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for health check"
  type        = number
  default     = 2
}
