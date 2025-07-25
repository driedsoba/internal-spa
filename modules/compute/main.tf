# Data sources for dynamic ARN construction
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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

# Least-privilege IAM policies
resource "aws_iam_policy" "lambda_direct_s3_upload_policy" {
  name = "DirectS3UploadLeastPrivilegePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::spa.chatwithjunle.com",
          "arn:aws:s3:::spa.chatwithjunle.com/*"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-direct-s3-upload-policy"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_policy" "lambda_admin_file_manager_policy" {
  name = "AdminFileManagerLeastPrivilegePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:GetObjectAttributes"
        ]
        Resource = [
          "arn:aws:s3:::spa.chatwithjunle.com",
          "arn:aws:s3:::spa.chatwithjunle.com/*"
        ]
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-admin-file-manager-policy"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_policy" "lambda_bucket_administrator_policy" {
  name = "BucketAdministratorLeastPrivilegePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketLifecycleConfiguration",
          "s3:GetBucketLifecycleConfiguration",
          "s3:PutBucketCors",
          "s3:GetBucketCors"
        ]
        Resource = "arn:aws:s3:::spa.chatwithjunle.com"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-bucket-administrator-policy"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

resource "aws_iam_policy" "lambda_list_s3_buckets_policy" {
  name = "ListS3BucketsLeastPrivilegePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "arn:aws:s3:::*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-list-s3-buckets-policy"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# Dynamic CloudWatch Logs policies (removing wildcards and hardcoded ARNs)
resource "aws_iam_policy" "lambda_logs_policy" {
  for_each = {
    DirectS3Upload      = "/aws/lambda/DirectS3Upload"
    AdminFileManager    = "/aws/lambda/AdminFileManager"
    BucketAdministrator = "/aws/lambda/BucketAdministrator"
    ListS3Buckets       = "/aws/lambda/ListS3Buckets"
  }

  name = "LambdaLogsPolicy-${each.key}"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${each.value}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${each.value}:*"
      }
    ]
  })

  tags = {
    Name      = "${var.project_name}-${each.key}-logs-policy"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# IAM Policy Attachments for Lambda Roles
# DirectS3Upload Role Policy Attachments
resource "aws_iam_role_policy_attachment" "direct_s3_upload_logs" {
  role       = aws_iam_role.lambda_directs3upload_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy["DirectS3Upload"].arn
}

resource "aws_iam_role_policy_attachment" "direct_s3_upload_s3_policy" {
  role       = aws_iam_role.lambda_directs3upload_role.name
  policy_arn = aws_iam_policy.lambda_direct_s3_upload_policy.arn
}

# AdminFileManager Role Policy Attachments
resource "aws_iam_role_policy_attachment" "admin_file_manager_logs" {
  role       = aws_iam_role.lambda_adminfilemanager_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy["AdminFileManager"].arn
}

resource "aws_iam_role_policy_attachment" "admin_file_manager_s3_policy" {
  role       = aws_iam_role.lambda_adminfilemanager_role.name
  policy_arn = aws_iam_policy.lambda_admin_file_manager_policy.arn
}

# ListS3Buckets Role Policy Attachments
resource "aws_iam_role_policy_attachment" "list_s3_buckets_logs" {
  role       = aws_iam_role.lambda_lists3buckets_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy["ListS3Buckets"].arn
}

resource "aws_iam_role_policy_attachment" "list_s3_buckets_s3_policy" {
  role       = aws_iam_role.lambda_lists3buckets_role.name
  policy_arn = aws_iam_policy.lambda_list_s3_buckets_policy.arn
}

# BucketAdministrator Role Policy Attachments
resource "aws_iam_role_policy_attachment" "bucket_administrator_logs" {
  role       = aws_iam_role.lambda_bucketadministrator_role.name
  policy_arn = aws_iam_policy.lambda_logs_policy["BucketAdministrator"].arn
}

resource "aws_iam_role_policy_attachment" "bucket_administrator_s3_policy" {
  role       = aws_iam_role.lambda_bucketadministrator_role.name
  policy_arn = aws_iam_policy.lambda_bucket_administrator_policy.arn
}
