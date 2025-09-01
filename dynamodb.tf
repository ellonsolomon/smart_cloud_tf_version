# DynamoDB table for photo metadata
resource "aws_dynamodb_table" "photo_gallery" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "photoId"

  attribute {
    name = "photoId"
    type = "S"
  }

  attribute {
    name = "uploadDate"
    type = "S"
  }

  global_secondary_index {
    name            = "DateIndex"
    hash_key        = "uploadDate"
    read_capacity   = var.dynamodb_read_capacity
    write_capacity  = var.dynamodb_write_capacity
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = var.dynamodb_table_name
    Type = "DynamoDB Table"
  })
}
