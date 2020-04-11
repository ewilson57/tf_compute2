variable "prefix" {
  description = "The prefix used for all resources"
  default     = "compute2"
}

variable "location" {
  description = "The Azure Region in which the resources should exist"
  default     = "East US 2"
}

variable "custom_image_resource_group_name" {
  description = "The name of the Resource Group in which the Custom Image exists."
  default     = "management-rg"
}

variable "custom_image_name" {
  description = "The name of the Custom Image to provision this Virtual Machine from."
  default     = "nginx_standard"
}

variable "router_wan_ip" {}
variable "admin_username" {}
variable "ssh_key" {}
