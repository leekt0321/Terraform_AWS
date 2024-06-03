output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "EC2 Public IP"
}

output "public_dns" {
  value       = aws_instance.example.public_dns
  description = "EC2 DNS name"
}

# 명령어
# tf output
# tf output public_ip
# tf output -raw public_ip  <- "" 제거

