output "address" {
  value       = aws_db_instance.mtdb_instance.address
  description = "DB Address"
}

output "port" {
  value       = aws_db_instance.mtdb_instance.port
  description = "DB Port"
}
