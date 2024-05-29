# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Variable declarations
variable "aws_region" {
    default="us-east-2"
    description = "AWS region"
    type = string
}

variable "vpc_cidr_block"{
    default="10.0.0.0/16"
    description = "VPC CIDR"
    type = string
}
variable "instance_count" {
  default=2
  description = "EC2 instance Count"
  type=number
}

variable "enable_vpn_gateway"{
    default=false
    description = "VPN Gateway 지원하지 않음"
    type=bool
}

variable "private_subnets_cidr_blocks" {
  default = [
    "10.0.101.0/24", 
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
    ]
  description = "private subnet CIDR"
  type=list(string)
}

variable "public_subnets_cidr_blocks" {
  default = [
    "10.0.1.0/24", 
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    ]
  description = "public subnet CIDR"
  type=list(string)
}

# 리스트 변수 사용 방법
# slice(var.public_subnets_cidr_blocks,0,2) 
# -> 10.0.1.0/24, 10.0.2.0/24

variable "private_subnets_count" {
  default =2
  description = "Private subnet count"
  type=number
}

variable "public_subnets_count" {
  default =2
  description = "Public subnet count"
  type=number
}
# slice(var.public_subnets_cidr_blocks,0,var.public_subnets_count) 


variable "resource_tags" {
  default={
    project = "project-alpha",
    environment="dev"
  }
  description = "Tags Name"
  type=map(string)
}

variable "instance_type" {
  description = "AWS EC2 instance type(ex: t2.micro): "
  type=string
}
# default값을 설정하지 않아 apply할때 직접 지정
# 디스크립션에 설명을 잘 해놔야 함.
