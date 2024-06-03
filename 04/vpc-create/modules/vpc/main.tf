# 1) VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.vpc_tags
}

# IGW 생성
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = var.gw_tags
}

# 2) Subnet 생성
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet
  tags       = var.subnet_tags
}


# Route Table + Default Route
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags = var.route_table_tags

  route = {
    cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
}

# Route Table <- association -> Subnet
resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}