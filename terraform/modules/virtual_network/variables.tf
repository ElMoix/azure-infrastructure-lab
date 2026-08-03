variable "name" {
  type = string
}

variable "common" {
  type = object({
    project_name = string
    location = string
    resource_group_name = string
    tags = map(string)
  })
}

variable "config" {
  type = object({
    address_space = list(string)
  })
}
