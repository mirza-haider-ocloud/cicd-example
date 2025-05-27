
# This file creates an S3 bucket & dynamoDB table
# to host the app's state file (for remote sharing)
# The actual infrastructure of the app is created by infra/main.tf


variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
  default     = "ci-cd-example-state"
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to create"
  type        = string
  default     = "ci_cd_example_locks"
}


provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning of state file
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enbale server-side encryption be default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Make dynamoDB table for locking state file
resource "aws_dynamodb_table" "terraform_locks" {
  name = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
