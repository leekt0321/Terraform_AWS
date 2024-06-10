output "myPrivate1_id" {
  description = "output : Private Subnet ID1"
  value       = aws_subnet.myPrivate1.id
}
output "myPrivate2_id" {
  description = "output : Private Subnet ID2"
  value       = aws_subnet.myPrivate2.id
}
output "myPublic1_id" {
  description = "output : Public Subnet ID1"
  value       = aws_subnet.myPublic1.id
}
output "myPublic2_id" {
  description = "output : Public Subnet ID2"
  value       = aws_subnet.myPublic2.id
}

output "vpc_id" {
  description = "output : VPC ID "
  value       = aws_vpc.myVPC.id
}