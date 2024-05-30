# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../data-sources-vpc/terraform.tfstate"
  }
}

provider "aws" {
  # region = "us-east-2"
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.0"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-tutorial-example"

  internal = false

  security_groups = data.terraform_remote_state.vpc.outputs.lb_security_group_ids
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  number_of_instances = length(aws_instance.app)
  instances           = aws_instance.app.*.id

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
}

data "aws_ami" "amazon_linux" {
  most_recent      = true
  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.*-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app" {
  #ami = "ami-04d29b6f966df1537"
  ami = data.aws_ami.amazon_linux.id
  count = var.instances_per_subnet * length(data.terraform_remote_state.vpc.outputs.private_subnet_ids) # 4: 0,1,2,3

  instance_type = var.instance_type

  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_ids[count.index % length(data.terraform_remote_state.vpc.outputs.private_subnet_ids)] # count.index = 순차적으로 카운트 1씩 증가 ex) 0,1,2,3,4,5
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.app_security_group_ids

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "<html><body><div>Hello, world!</div></body></html>" > /var/www/html/index.html
    EOF
}
