# S3 Bucket
resource "aws_s3_bucket" "spa_bucket" {
  bucket = var.bucket_name

  tags = {
    Name      = var.bucket_name
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}
