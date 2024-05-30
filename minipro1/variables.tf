variable "myPubSN_tags" {
  default = {
    Name = "myPubSN"
  }
  description = "Public Subnet tags"
  type        = map(string)
}

variable "myDocker_tags" {
  default = {
    Name = "myDocker"
  }
  description = "EC2 tags"
  type        = map(string)
}
