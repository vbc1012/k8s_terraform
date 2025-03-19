provider "aws" {
  region = "us-east-1" # Replace with your region
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "tf_state" {
  bucket = "my-k8s-terraform-state" # Replace with your unique bucket name

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Enable Versioning on the S3 Bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block Public Access to the S3 Bucket
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock_k8s" # Replace with your table name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}

# Output the Bucket Name and DynamoDB Table Name
output "s3_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}
