variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  type        = string

}

variable "instance_tenancy" {
  default     = "default"
  description = "VPC Instance Tenancy"
  type        = string
}

variable "vpc_tags" {
  default = {
    Name = "main"
  }
  description = "VPC tags"
  type        = map(string)
}

variable "gw_tags" {
  default = {
    Name = "main"
  }
  type = map(string)
}

variable "public_subnet" {
  default     = "10.0.1.0/24"
  description = "VPC public subnet"
  type        = string
}

variable "subnet_tags" {
  default = {
    Name = "Main"
  }
  description = "VPC Public Subnet"
  type        = map(string)
}

variable "az" {
  description = "(required) VPC Selected AZ"
  type = string
}

variable "route_table_tags" {
  default = {
    Name = "main"
  }
  description = "Route Table Tags"
  type = map(string)
}