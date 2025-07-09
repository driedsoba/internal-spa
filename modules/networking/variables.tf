variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "spa"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1a_cidr" {
  description = "CIDR block for subnet 1a"
  type        = string
  default     = "10.0.128.0/20"
}

variable "subnet_1c_cidr" {
  description = "CIDR block for subnet 1c"
  type        = string
  default     = "10.0.16.0/20"
}

variable "availability_zone_1a" {
  description = "Availability zone for subnet 1a"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_1c" {
  description = "Availability zone for subnet 1c"
  type        = string
  default     = "ap-southeast-1c"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access ALB"
  type        = list(string)
  default     = ["118.189.14.110/32"]
}

variable "external_sg_id" {
  description = "External security group ID to reference"
  type        = string
  default     = "sg-0fdcb91c73d323b2c"
}