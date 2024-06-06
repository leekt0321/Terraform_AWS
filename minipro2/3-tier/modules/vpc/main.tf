 # VPC

resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags={
    Name = "myVPC"
  }
}

# igw
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# subnet x4(public x2, private x2)
resource "aws_subnet" "myPublic1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "myPublic1"
  }
}
resource "aws_subnet" "myPublic2" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPublic2"
  }
}
resource "aws_subnet" "myPrivate1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "myPrivate1"
  }
}
resource "aws_subnet" "myPrivate2" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    Name = "myPrivate2"
  }
}

# Elastic IP
resource "aws_eip" "nat_ip1" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_eip" "nat_ip2" {
  domain= "vpc"
  lifecycle {
    create_before_destroy = true
  }
}

# NAT gateway
resource "aws_nat_gateway" "natGW1" {
  allocation_id = aws_eip.nat_ip1.id
  subnet_id     = aws_subnet.myPublic1.id
  connectivity_type = "public"

  tags = {
    Name = "gw NAT1"
  }

  depends_on = [aws_internet_gateway.myIGW]
}

resource "aws_nat_gateway" "natGW2" {
  allocation_id = aws_eip.nat_ip2.id
  subnet_id     = aws_subnet.myPublic2.id
  connectivity_type = "public"

  tags = {
    Name = "gw NAT2"
  }

  depends_on = [aws_internet_gateway.myIGW]
}

################## RT
resource "aws_route_table" "PubRT1" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "PubRT1"
  }
}
resource "aws_route_table" "PubRT2" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "PubRT2"
  }
}
resource "aws_route_table" "PriRT1" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natGW1.id
  }

  tags = {
    Name = "PriRT1"
  }
}
resource "aws_route_table" "PriRT2" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natGW2.id
  }

  tags = {
    Name = "PriRT2"
  }
}

#############3 RT - Sub
resource "aws_route_table_association" "pub1" {
  subnet_id      = aws_subnet.myPublic1.id
  route_table_id = aws_route_table.PubRT1.id
}
resource "aws_route_table_association" "pub2" {
  subnet_id      = aws_subnet.myPublic2.id
  route_table_id = aws_route_table.PubRT2.id
}
resource "aws_route_table_association" "pri1" {
  subnet_id      = aws_subnet.myPrivate1.id
  route_table_id = aws_route_table.PriRT1.id
}
resource "aws_route_table_association" "pri2" {
  subnet_id      = aws_subnet.myPrivate2.id
  route_table_id = aws_route_table.PriRT2.id
}



resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_web" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# userdata
/*data "terraform_remote_state" "my_remote_state" {
  backend = "s3"

  config = {
    bucket="mybucket-lee-1234"
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table= "myDyDB"
  }
}*/

# LC
data "aws_ami" "ubuntu" {
  most_recent      = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners           = ["099720109477"]

}

resource "aws_launch_configuration" "myLC" {
  name_prefix   = "myLC-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.mySG.id]
  user_data = file("~/tf/minipro2/3-tier/modules/vpc/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "myASG" {
  name                 = "myASG"
  launch_configuration = aws_launch_configuration.myLC.name
  min_size             = 2
  max_size             = 5
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.myPublic1.id,aws_subnet.myPublic2.id,aws_subnet.myPrivate1.id,aws_subnet.myPrivate2.id]
  target_group_arns = [aws_lb_target_group.myTG.arn]
  depends_on=[aws_lb_target_group.myTG]

  lifecycle {
    create_before_destroy = true
  }
}

# TG
resource "aws_lb_target_group" "myTG" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id

  health_check {
    path="/"
    port=80
    protocol = "HTTP"
    matcher = "200"
    interval = 10
    timeout = 3
  }

}

# LB
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.myPublic1.id,aws_subnet.myPublic2.id] # public만 사용한다.(private x)

  tags = {
    Name="myALB"
  }
}

# LB listener
resource "aws_lb_listener" "myListener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTG.arn
  }
}

