# API Gateway endpoint URL
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "https://${aws_api_gateway_rest_api.photo_gallery.id}.execute-api.${var.region}.amazonaws.com/${var.environment}"
}

# API Gateway ID
output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.photo_gallery.id
}

# S3 bucket name
output "s3_bucket_name" {
  description = "S3 bucket name for photo storage"
  value       = aws_s3_bucket.photo_gallery.bucket
}

# S3 bucket ARN
output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.photo_gallery.arn
}

# DynamoDB table name
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.photo_gallery.name
}

# DynamoDB table ARN
output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.photo_gallery.arn
}

# Lambda function names
output "lambda_function_names" {
  description = "Lambda function names"
  value = {
    list   = aws_lambda_function.list_photos.function_name
    upload = aws_lambda_function.upload_photo.function_name
    delete = aws_lambda_function.delete_photo.function_name
  }
}

# Lambda function ARNs
output "lambda_function_arns" {
  description = "Lambda function ARNs"
  value = {
    list   = aws_lambda_function.list_photos.arn
    upload = aws_lambda_function.upload_photo.arn
    delete = aws_lambda_function.delete_photo.arn
  }
}

# IAM role ARN
output "lambda_role_arn" {
  description = "IAM role ARN for Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}

# Region
output "aws_region" {
  description = "AWS region"
  value       = var.region
}

# Account ID
output "aws_account_id" {
  description = "AWS account ID"
  value       = local.account_id
}

# Deployment timestamp
output "deployment_timestamp" {
  description = "Deployment timestamp"
  value       = local.timestamp
}

# Resource URLs for easy access
output "resource_urls" {
  description = "Quick access URLs for AWS console"
  value = {
    s3_console          = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.photo_gallery.bucket}"
    dynamodb_console    = "https://${var.region}.console.aws.amazon.com/dynamodbv2/home?region=${var.region}#item-explorer?table=${aws_dynamodb_table.photo_gallery.name}"
    api_gateway_console = "https://${var.region}.console.aws.amazon.com/apigateway/home?region=${var.region}#/apis/${aws_api_gateway_rest_api.photo_gallery.id}/stages/${var.environment}"
    lambda_console      = "https://${var.region}.console.aws.amazon.com/lambda/home?region=${var.region}#/functions"
  }
}

# Summary information
output "deployment_summary" {
  description = "Deployment summary information"
  value = {
    api_endpoint   = "https://${aws_api_gateway_rest_api.photo_gallery.id}.execute-api.${var.region}.amazonaws.com/${var.environment}"
    s3_bucket      = aws_s3_bucket.photo_gallery.bucket
    dynamodb_table = aws_dynamodb_table.photo_gallery.name
    region         = var.region
    environment    = var.environment
  }
}
