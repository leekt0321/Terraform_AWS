# 프로바이더(리전) 설정
provider "aws" {
  region = "us-east-2"
}

# S3 버킷 생성
resource "aws_s3_bucket" "myS3_remote_state" {
  bucket = "mybucket-lee-2952"
  force_destroy = true

  tags = {
    Name        = "mybucket"
  }
}

# DynamoDb table 생성
resource "aws_dynamodb_table" "myDyDB_remote_state" {
  name           = "myDyDB_remote_state"
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}