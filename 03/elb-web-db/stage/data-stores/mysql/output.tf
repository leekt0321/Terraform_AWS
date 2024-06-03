output "address" {
  value       = aws_db_instance.mydb_instance.address
  description = "DB Address"
}

output "port" {
  value       = aws_db_instance.mydb_instance.port
  description = "DB Port"
}
