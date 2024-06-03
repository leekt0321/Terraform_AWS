# 인프라 구성: VPC, Subnet, IGW, NAT, ...

# 1. 인프라 구성: VPC, Subnet, IGW, NAT, ...
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# 구성 목표: ELB + ASG

# 1) ASG 구성
#
# 시작 템플릿 구성
# ASG 생성

# Launch Configuration + Auto Scaling Group

# 이미지
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

  owners = ["099720109477"] # Canonical
}

# 보안 그룹 생성 - LC를 위한 보안 그룹

resource "aws_security_group" "mySGforLC" {
  name        = "mySGforLC"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "mySGforLC"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080" {
  security_group_id = aws_security_group.mySGforLC.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.inport_web
  ip_protocol       = "tcp"
  to_port           = var.outport_web
}

resource "aws_vpc_security_group_ingress_rule" "allow_22" {
  security_group_id = aws_security_group.mySGforLC.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.inport_ssh
  ip_protocol       = "tcp"
  to_port           = var.outport_ssh
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.mySGforLC.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# 시작 템플릿 구성
resource "aws_launch_configuration" "myLC" {
  name_prefix     = "myLC-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.mySGforLC.id]

  user_data = file("userdata.tpl")

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

  # 대상 그룹 만든 후 다시 설정(중요)
  target_group_arns = [aws_lb_target_group.myTGASG.arn]
  depends_on        = [aws_lb_target_group.myTGASG]
  # placement_group = aws_placement_group.test.id

  vpc_zone_identifier = data.aws_subnets.default.ids


  lifecycle {
    create_before_destroy = true
  }
}

# 2) ELB 구성
# 타겟 그룹 생성
# ELB 리스너
# ELB 리스너 규칙

# ELB

resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySGforLC.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Environment = "production"
  }
}

# TG 생성
resource "aws_lb_target_group" "myTGASG" {
  name     = "myTGASG"
  port     = var.inport_web
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = var.inport_web
    matcher             = "200"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

# ELB Listener
resource "aws_lb_listener" "myALBListener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = var.inport_web
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myTGASG.arn
  }
}