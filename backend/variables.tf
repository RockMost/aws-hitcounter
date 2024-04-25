variable "name" {
  description = "Visitor_counter"
  default     = "counter"
}
variable "env" {
  description = "Visitor_counter"
  default     = "hitc"
}
locals {
  full_name = "${var.env}-${var.name}"
}