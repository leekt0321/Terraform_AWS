# tf state list
# tf state show aws_instance.myInstance 를 통해 확인 후
# value에 넣는다.

output "ami_id" {
  value = aws_instance.myInstance.ami
  description = "EC2 AMI ID"
}