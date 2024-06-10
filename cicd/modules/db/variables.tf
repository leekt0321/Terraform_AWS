variable "dbuser" {
  description = "DB Admin Name"
  type = string
  sensitive = true
}

variable "dbpassword" {
    description = "DB Admin Password"
    type = string
    sensitive = true
}

variable "myPrivate1_id" {
  description = "The Private Subnet ID1 for the ASG"
  type        = string
}

variable "myPrivate2_id" {
  description = "The Private Subnet ID2 for the ASG"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

