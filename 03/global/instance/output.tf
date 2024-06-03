output "ec2_instance_ip" {
  value       = aws_instance.myinstance.public_ip
  description = "ec2 public ip"
}