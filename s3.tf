# S3 bucket for photo storage
resource "aws_s3_bucket" "photo_gallery" {
  bucket        = local.bucket_name
  force_destroy = true # Allow Terraform to delete bucket even with objects


  tags = merge(local.common_tags, {
    Name = local.bucket_name
    Type = "S3 Bucket"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "photo_gallery" {
  bucket = aws_s3_bucket.photo_gallery.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "photo_gallery" {
  bucket = aws_s3_bucket.photo_gallery.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "photo_gallery" {
  bucket = aws_s3_bucket.photo_gallery.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "photo_gallery" {
  bucket = aws_s3_bucket.photo_gallery.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag", "x-amz-server-side-encryption"]
    max_age_seconds = 3000
  }
}
