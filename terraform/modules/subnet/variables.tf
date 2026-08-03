variable "common" {
  type = object({
    project_name = string
    location = string
    resource_group_name = string
    tags = map(string)
  })
}

variable "name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "config" {
  type = object({
    virtual_network = string
    address_prefix = string
  })
}
