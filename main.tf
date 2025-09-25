provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# Get current AWS account ID and caller identity
data "aws_caller_identity" "current" {}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

# Generate timestamp for unique naming
locals {
  timestamp   = formatdate("YYYYMMDDHHmmss", timestamp())
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = "${var.project_name}-${local.timestamp}-${random_string.suffix.result}"

  common_tags = merge(var.tags, {
    AccountId = local.account_id
    Region    = var.region
  })
}
