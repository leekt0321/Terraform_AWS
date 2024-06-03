variable "dbuser" {
  description = "DB Admin Name"
  type        = string
  sensitive   = true
}
variable "dbpassword" {
  description = "DB Admin Password"
  type        = string
  sensitive   = true
}