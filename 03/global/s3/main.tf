# 프로바이더 설정
provider "aws" {
  region = "us-east-2"
}

# s3 버킷 생성(terraform remote state)
resource "aws_s3_bucket" "remote_state" {
  bucket        = "mybucket-lee-2952"
  force_destroy = true

  tags = {
    Name = "mybucket"
  }
}

# DynamoDB Table 생성(LockID)
resource "aws_dynamodb_table" "myLocks" {
  name         = "myLocks"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}