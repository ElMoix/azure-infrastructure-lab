resource "azurerm_virtual_network" "this" {
  name = "${var.common.project_name}-${var.name}-vnet"
  location = var.common.location
  resource_group_name = var.common.resource_group_name
  address_space = var.config.address_space
}
