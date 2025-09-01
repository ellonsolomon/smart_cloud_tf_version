# Lambda function for photo listing
resource "aws_lambda_function" "list_photos" {
  filename         = "lambda_list.zip"
  function_name    = "${var.project_name}-list"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  source_code_hash = data.archive_file.lambda_list_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_gallery.bucket
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_iam_role_policy.lambda_dynamodb,
    aws_iam_role_policy.lambda_s3,
    aws_cloudwatch_log_group.lambda_list_logs,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-list"
    Type = "Lambda Function"
  })
}

# Lambda function for photo upload
resource "aws_lambda_function" "upload_photo" {
  filename         = "lambda_upload.zip"
  function_name    = "${var.project_name}-upload"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  source_code_hash = data.archive_file.lambda_upload_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_gallery.bucket
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_iam_role_policy.lambda_dynamodb,
    aws_iam_role_policy.lambda_s3,
    aws_cloudwatch_log_group.lambda_upload_logs,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-upload"
    Type = "Lambda Function"
  })
}

# Lambda function for photo deletion
resource "aws_lambda_function" "delete_photo" {
  filename         = "lambda_delete.zip"
  function_name    = "${var.project_name}-delete"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  source_code_hash = data.archive_file.lambda_delete_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_gallery.bucket
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_iam_role_policy.lambda_dynamodb,
    aws_iam_role_policy.lambda_s3,
    aws_cloudwatch_log_group.lambda_delete_logs,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-delete"
    Type = "Lambda Function"
  })
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_list_logs" {
  name              = "/aws/lambda/${var.project_name}-list"
  retention_in_days = 7

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_upload_logs" {
  name              = "/aws/lambda/${var.project_name}-upload"
  retention_in_days = 7

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_delete_logs" {
  name              = "/aws/lambda/${var.project_name}-delete"
  retention_in_days = 7

  tags = local.common_tags
}

# Archive the Lambda function source code
data "archive_file" "lambda_list_zip" {
  type        = "zip"
  output_path = "lambda_list.zip"

  source {
    content = templatefile("${path.module}/lambda_functions/list.py", {
      table_name = var.dynamodb_table_name
    })
    filename = "lambda_function.py"
  }
}

data "archive_file" "lambda_upload_zip" {
  type        = "zip"
  output_path = "lambda_upload.zip"

  source {
    content = templatefile("${path.module}/lambda_functions/upload.py", {
      table_name = var.dynamodb_table_name
    })
    filename = "lambda_function.py"
  }
}

data "archive_file" "lambda_delete_zip" {
  type        = "zip"
  output_path = "lambda_delete.zip"

  source {
    content = templatefile("${path.module}/lambda_functions/delete.py", {
      table_name = var.dynamodb_table_name
    })
    filename = "lambda_function.py"
  }
}
