output "ec2_dns_name" {
  value = aws_instance.myDocker.public_ip
  description = "EC2 instance public ip"
}