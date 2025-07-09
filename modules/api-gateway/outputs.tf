output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.spa_api.id
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.spa_api.execution_arn
}

output "api_gateway_root_resource_id" {
  description = "Root resource ID of the API Gateway"
  value       = aws_api_gateway_rest_api.spa_api.root_resource_id
}
