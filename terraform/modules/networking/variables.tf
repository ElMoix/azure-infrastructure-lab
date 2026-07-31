variable "project_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "vnet-azure-lab"
}

variable "subnet_name" {
  type    = string
  default = "subnet-azure-lab"
}

variable "nsg_name" {
  type    = string
  default = "nsg-azure-lab"
}
