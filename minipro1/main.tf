# VPC 생성
# IGW 생성
# IGW를 VPC에 연결

# Public Subnet 생성
# PublicRT 생성
# Public Subnet에 PublicRT 연결

# SG 생성
# SSH 키 생성
# EC2 생성
# - user_data(docker 설치)

# PC에서 EC2 연결

#################
# 1. VPC 생성
#################

# 1) VPC 생성
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support= true
  enable_dns_hostnames = true
  
  tags = {
    Name = "myVPC"
  }
}
# 2) IGW 생성
# 3) IGW를 VPC에 연결