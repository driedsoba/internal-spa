output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_private_1a_id" {
  description = "ID of the private subnet 1a"
  value       = aws_subnet.private_1a.id
}

output "subnet_private_1c_id" {
  description = "ID of the private subnet 1c"
  value       = aws_subnet.private_1c.id
}

output "subnet_ids" {
  description = "List of all subnet IDs"
  value       = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "s3_interface_security_group_id" {
  description = "ID of the S3 interface security group"
  value       = aws_security_group.s3_interface_sg.id
}

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3_interface.id
}