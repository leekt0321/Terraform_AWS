output "s3_remote_state" {
  value       = aws_s3_bucket.remote_state.arn
  description = "s3 bucket remote state ARN"
}

output "dydb_remote_state" {
  value       = aws_dynamodb_table.myLocks.id
  description = "DynamoDB Table name"
}