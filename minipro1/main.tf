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
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# 2) IGW 생성 및 연결
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

#############################
# 2. PubSN 생성
#############################
# 1) PubSN 생성
resource "aws_subnet" "myPubSN" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = var.myPubSN_tags
}

# 2) PubRT 생성
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

# 3) PubSN에  PubRT을 연결
resource "aws_route_table_association" "myPubSNassoc" {
  subnet_id      = aws_subnet.myPubSN.id
  route_table_id = aws_route_table.myPubRT.id
}

####################
# 3. EC2 생성
####################
# 1) SG 생성
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow all  inbound traffic and outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_out_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# 2) SSH Key 생성
# (*NIX) ssh-keygen -t rsa  -> 사용자가 직접 생성한다.
# key pair 작업
resource "aws_key_pair" "myleekey" {
  key_name   = "myleekey"
  public_key = file("~/.ssh/leekey.pub")
}

# 3) EC2 생성
# - ami_id
# - user_data(docker 설치)
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "myDocker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.myleekey.key_name
  vpc_security_group_ids = [aws_security_group.mySG.id]
  subnet_id = aws_subnet.myPubSN.id
  #user_data = file()
  tags = var.myDocker_tags
}


# 접속 
# ssh -i ~/.ssh/leekey ubuntu@$(tf output -raw ec2_dns_name)