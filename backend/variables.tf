variable "name" {
  description = "Name of application"
  default     = "demo1"
}
variable "env" {
  description = "Environment name"
  default     = "hitc"
}
locals {
  full_name = "${var.env}-${var.name}"
}