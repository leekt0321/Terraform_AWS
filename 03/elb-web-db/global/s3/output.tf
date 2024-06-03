output "s3_bucket_arn" {
  value       = aws_s3_bucket.myS3_remote_state.arn
  description = "S3 Bucket ARN Name"
}

output "DyDB_table_name" {
  value       = aws_dynamodb_table.myDyDB_remote_state.name
  description = "DynamoDB Table Name"
}

