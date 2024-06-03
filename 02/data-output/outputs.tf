# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output declarations
output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}

output "lb_url" {
  value       = "http://${module.elb_http.elb_dns_name}/"
  description = "ELB DNS URL"
}

output "web_server_count" {
  value       = length(module.ec2_instances.instance_ids)
  description = "EC2 total count"
}

output "db_username" {
  description = "Database administrator username"
  value       = aws_db_instance.database.username
  sensitive   = true
}

output "db_password" {
  description = "Database administrator password"
  value       = aws_db_instance.database.password
  sensitive   = true
}