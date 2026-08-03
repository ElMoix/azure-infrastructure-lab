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

variable "subnet_id" {
  type = string
}

variable "config" {
  type = object({
    subnet = string
  })
}
