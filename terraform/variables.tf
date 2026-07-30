variable "project_name" {
  description = "Project prefix"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
}

variable "admin_username" {
  description = "VM admin user"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet CIDR"
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "Subnet CIDR"
  type        = list(string)
}

variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
