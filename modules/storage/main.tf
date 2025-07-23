# S3 Bucket
resource "aws_s3_bucket" "spa_bucket" {
  bucket = var.bucket_name

  tags = {
    Name      = var.bucket_name
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "spa_bucket_encryption" {
  bucket = aws_s3_bucket.spa_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = ""
    }

  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "spa_bucket_public_access_block" {
  bucket = aws_s3_bucket.spa_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "spa_bucket_policy" {
  bucket = aws_s3_bucket.spa_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "VPCE"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.spa_bucket.arn}/*",
          aws_s3_bucket.spa_bucket.arn
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      }
    ]
  })
}