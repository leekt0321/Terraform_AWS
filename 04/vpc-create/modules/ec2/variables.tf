variable "instance_type" {
  default = "t2.micro"
  description = "EC2 Instance Type"
  type = string
}

variable "instance_tags" {
  default = {
    Name = "web"
  }
  description = "Instance Tags"
  type = map(string)
}

variable "instance_conut" {
  default = 2
  description = "instance Count"
  type = number
}

variable "subnet_id" {
  description = "(required) VPC Subnet ID"
  type = string
}