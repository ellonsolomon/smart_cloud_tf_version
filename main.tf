terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
}

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
  timestamp   = formatdate("YYYYMMDDHHMMSS", timestamp())
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = "${var.project_name}-${local.timestamp}-${random_string.suffix.result}"

  common_tags = merge(var.tags, {
    AccountId = local.account_id
    Region    = var.region
  })
}
