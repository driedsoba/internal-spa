# Create lambda-packages directory for zip files
resource "null_resource" "create_lambda_packages_dir" {
  provisioner "local-exec" {
    command = var.create_dir_command
  }
}

# Lambda Function Packaging
data "archive_file" "direct_s3_upload_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_dir}/DirectS3Upload.js"
  output_path = "${var.lambda_packages_dir}/DirectS3Upload.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "admin_file_manager_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_dir}/AdminFileManager.mjs"
  output_path = "${var.lambda_packages_dir}/AdminFileManager.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "bucket_administrator_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_dir}/BucketAdministrator.mjs"
  output_path = "${var.lambda_packages_dir}/BucketAdministrator.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

data "archive_file" "list_s3_buckets_zip" {
  type        = "zip"
  source_file = "${var.lambda_source_dir}/ListS3Buckets.mjs"
  output_path = "${var.lambda_packages_dir}/ListS3Buckets.zip"
  depends_on  = [null_resource.create_lambda_packages_dir]
}

# IAM Roles
resource "aws_iam_role" "lambda_adminfilemanager_role" {
  name = "AdminFileManager-role-8e5nfd3s"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name      = "${var.project_name}-AdminFileManager-role"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_role" "lambda_bucketadministrator_role" {
  name = "BucketAdministrator-role-pnbrbddo"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name      = "${var.project_name}-BucketAdministrator-role"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_role" "lambda_directs3upload_role" {
  name = "DirectS3Upload-role-zviwdm3v"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name      = "${var.project_name}-DirectS3Upload-role"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_role" "lambda_lists3buckets_role" {
  name = "ListS3Buckets-role-upaksby2"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name      = "${var.project_name}-ListS3Buckets-role"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# Lambda Functions
resource "aws_lambda_function" "admin_file_manager" {
  filename         = data.archive_file.admin_file_manager_zip.output_path
  function_name    = "AdminFileManager"
  handler          = var.lambda_handler
  memory_size      = var.lambda_memory_size
  role             = aws_iam_role.lambda_adminfilemanager_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.admin_file_manager_zip.output_base64sha256
  timeout          = var.lambda_timeout

  tags = {
    Name      = "${var.project_name}-AdminFileManager"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_lambda_function" "bucket_administrator" {
  filename         = data.archive_file.bucket_administrator_zip.output_path
  function_name    = "BucketAdministrator"
  handler          = var.lambda_handler
  memory_size      = var.lambda_memory_size
  role             = aws_iam_role.lambda_bucketadministrator_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.bucket_administrator_zip.output_base64sha256
  timeout          = var.lambda_timeout

  tags = {
    Name      = "${var.project_name}-BucketAdministrator"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_lambda_function" "direct_s3_upload" {
  filename         = data.archive_file.direct_s3_upload_zip.output_path
  function_name    = "DirectS3Upload"
  handler          = var.lambda_handler
  memory_size      = var.lambda_memory_size
  role             = aws_iam_role.lambda_directs3upload_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.direct_s3_upload_zip.output_base64sha256
  timeout          = var.lambda_timeout

  tags = {
    Name      = "${var.project_name}-DirectS3Upload"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_lambda_function" "list_s3_buckets" {
  filename         = data.archive_file.list_s3_buckets_zip.output_path
  function_name    = "ListS3Buckets"
  handler          = var.lambda_handler
  memory_size      = var.lambda_memory_size
  role             = aws_iam_role.lambda_lists3buckets_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = data.archive_file.list_s3_buckets_zip.output_base64sha256
  timeout          = var.lambda_timeout

  tags = {
    Name      = "${var.project_name}-ListS3Buckets"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "lambda_log_groups" {
  for_each = {
    AdminFileManager    = "/aws/lambda/AdminFileManager"
    BucketAdministrator = "/aws/lambda/BucketAdministrator"
    DirectS3Upload      = "/aws/lambda/DirectS3Upload"
    ListS3Buckets       = "/aws/lambda/ListS3Buckets"
  }

  name              = each.value
  retention_in_days = 1
  tags = {
    Name      = "${var.project_name}-${each.key}-logs"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}
