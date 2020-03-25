variable "prefix" {
  description = "The prefix used for all resources"
  default     = "compute2"
}

variable "location" {
  description = "The Azure Region in which the resources should exist"
  default     = "East US 2"
}

variable "router_wan_ip" {}
variable "admin_username" {}
variable "ssh_key" {}
