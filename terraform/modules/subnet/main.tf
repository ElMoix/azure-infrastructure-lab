resource "azurerm_subnet" "this" {
  name = "${var.common.project_name}-${var.name}-subnet"
  resource_group_name = var.common.resource_group_name
  
  virtual_network_name = var.virtual_network_name
  address_prefixes = [
    var.config.address_prefix
  ]
}
