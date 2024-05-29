# VPC 생성
# Public Subnet 생성
# Routing Table 생성
# Routing Table <-> Public Subnet 연결
# Security Group 생성
# EC2 생성


provider "aws" {
    region = "us-east-2"
}

# 1) VPC 만들기

resource "aws_vpc" "myVPC"{
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true


    tags ={
        Name ="myVPC"
    }
}

# 1) public Subnet 생성

resource "aws_subnet" "myPublicSubnet" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch=true

  tags = {
    Name = "myPublicSubnet"
  }
}

# 2) Internet Gateway 생성

resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# 2) Public Routing Table 생성

resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

# 2-1) Public Routing Table를 Public Subnet에 연결
resource "aws_route_table_association" "myRTass" {
  subnet_id      = aws_subnet.myPublicSubnet.id
  route_table_id = aws_route_table.myPubRT.id
}


# security_group
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "allow_web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myHTTP" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "mySSH" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# 3) EC2 생성

resource "aws_instance" "myWEB" {
  ami           = "ami-0ca2e925753ca2fb4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.myPublicSubnet.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  # associate_public_ip_address = true -> VPC에 public ip를 연결할지 말지?

  # 유저 데이터 destroy하고 replace가능하게 해주는 옵션(테스트할떄 사용 정삭작동하면 주석처리하자)
  user_data_replace_on_change=true
  user_data = <<-EOF
    #!/bin/bash
    sudo yum -y install httpd
    sudo echo 'HI WEB' > /var/www/html/index.html
    sudo systemctl enable --now httpd
    EOF

  tags = {
    Name = "myWEB"
  }
}