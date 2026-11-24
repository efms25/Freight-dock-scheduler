
# =============================================================================
# s3.tf — Bucket S3 para documentos FDS
# =============================================================================

resource "aws_s3_bucket" "fds_docs" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "fds_docs" {
  bucket = aws_s3_bucket.fds_docs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "fds_docs" {
  bucket = aws_s3_bucket.fds_docs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "fds_docs" {
  bucket                  = aws_s3_bucket.fds_docs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
