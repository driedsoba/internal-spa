# Lambda Function ARNs
output "admin_file_manager_arn" {
  description = "ARN of the AdminFileManager Lambda function"
  value       = aws_lambda_function.admin_file_manager.arn
}

output "bucket_administrator_arn" {
  description = "ARN of the BucketAdministrator Lambda function"
  value       = aws_lambda_function.bucket_administrator.arn
}

output "direct_s3_upload_arn" {
  description = "ARN of the DirectS3Upload Lambda function"
  value       = aws_lambda_function.direct_s3_upload.arn
}

output "list_s3_buckets_arn" {
  description = "ARN of the ListS3Buckets Lambda function"
  value       = aws_lambda_function.list_s3_buckets.arn
}

# Lambda Function Names
output "admin_file_manager_name" {
  description = "Name of the AdminFileManager Lambda function"
  value       = aws_lambda_function.admin_file_manager.function_name
}

output "bucket_administrator_name" {
  description = "Name of the BucketAdministrator Lambda function"
  value       = aws_lambda_function.bucket_administrator.function_name
}

output "direct_s3_upload_name" {
  description = "Name of the DirectS3Upload Lambda function"
  value       = aws_lambda_function.direct_s3_upload.function_name
}

output "list_s3_buckets_name" {
  description = "Name of the ListS3Buckets Lambda function"
  value       = aws_lambda_function.list_s3_buckets.function_name
}

# IAM Role ARNs
output "admin_file_manager_role_arn" {
  description = "ARN of the AdminFileManager IAM role"
  value       = aws_iam_role.lambda_adminfilemanager_role.arn
}

output "bucket_administrator_role_arn" {
  description = "ARN of the BucketAdministrator IAM role"
  value       = aws_iam_role.lambda_bucketadministrator_role.arn
}

output "direct_s3_upload_role_arn" {
  description = "ARN of the DirectS3Upload IAM role"
  value       = aws_iam_role.lambda_directs3upload_role.arn
}

output "list_s3_buckets_role_arn" {
  description = "ARN of the ListS3Buckets IAM role"
  value       = aws_iam_role.lambda_lists3buckets_role.arn
}
