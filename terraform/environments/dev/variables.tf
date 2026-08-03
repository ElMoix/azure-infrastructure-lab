variable "virtual_networks" {
  type = map(object({
    address_space = list(string)
  }))
  default = {}
}

variable "subnets" {
  type = map(object({
    virtual_network = string
    address_prefix = string
  }))
  default = {}
}

variable "nsgs" {
  type = map(object({
    subnet = string
  }))
  default = {}
}
