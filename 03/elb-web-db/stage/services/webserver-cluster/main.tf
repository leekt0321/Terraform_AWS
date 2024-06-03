# 프로바이더(리전) 설정
provider "aws" {
  region = "us-east-2"
}

############################
# 1. VPC 생성
############################
# Default VPC, Default Subnet
# 1) Default VPC
data "aws_vpc" "default" {
  default = true
}

# 2) Default Subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################
# 2. ALB + ASG
############################
# 1) ASG
#   * SG
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_web" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
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

# User Data 생성(s3에 있는 데이터 참조)
data "terraform_remote_state" "my_remote_state" {
  backend = "s3"

  config = {
    bucket = "mybucket-lee-2952"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"

  }
}

#   * LC
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

resource "aws_launch_configuration" "myLC" {
  name_prefix   = "myLC-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # 추가 고려 사항
  # SG
  security_groups = [aws_security_group.mySG.id]
  # user_data
  user_data = templatefile("user_data.sh", {
    db_address = data.terraform_remote_state.my_remote_state.outputs.address
    db_port    = data.terraform_remote_state.my_remote_state.outputs.port
  })

  lifecycle { # userdata사용시 초기에 꼭 필요, 나중에 false로 바꾼다.
    create_before_destroy = true
  }
}

#   * ASG
resource "aws_autoscaling_group" "myASG" {
  name                 = "myASG"
  launch_configuration = aws_launch_configuration.myLC.name
  min_size             = 2
  max_size             = 5

  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = data.aws_subnets.default.ids
  ############################
  # (주의) TG 지정 필요
  ############################

  lifecycle {
    create_before_destroy = true
  }
}


# 2) ALB
#   * TG(ASG) - depane on
/*
resource "aws_lb_target_group" "myTG" {
  name     = "myTG"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    port = 8080
    protocol = "HTTP"
    matcher = "200" # 응답코드
    interval = 10
    timeout = 3 
    healthy_threshold = 3 # 기본값이 3이라 선언안해도됨
    unhealthy_threshold = 3 # 기본값이 3이라 선언안해도됨

  }
}
*/
#   * LB
#   * LB Listener
#   * LB Listener Rule


