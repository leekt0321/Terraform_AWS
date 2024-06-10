provider "aws" {
  region ="ap-northeast-2"
}

resource "aws_s3_bucket" "myBucket" {
  bucket = "mybucket-lee-1234"
  force_destroy = true

  tags = {
    Name = "mybucket"
  }
}

resource "aws_dynamodb_table" "myDyDB" {
  name = "myDyDB"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}