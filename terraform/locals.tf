locals {
  resource_group_name = "rg-${var.project_name}"

  vnet_name = "vnet-${var.project_name}"

  subnet_name = "subnet-${var.project_name}"

  nsg_name = "nsg-${var.project_name}"

  public_ip_name = "pip-${var.project_name}"

  nic_name = "nic-${var.project_name}"

  vm_name = "vm-${var.project_name}"

  tags = {
    Project     = var.project_name
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
