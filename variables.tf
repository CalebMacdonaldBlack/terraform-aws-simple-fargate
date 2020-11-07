variable "lb_listener_certificate_arn" {
  description = "The arn for the load balancer listener ssl certificate."
  type        = string
}

variable "name_prefix" {
  default = "The name prefix of the resources created in this module."
  type = string
}