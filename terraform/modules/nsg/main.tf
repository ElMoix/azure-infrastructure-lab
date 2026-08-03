resource "azurerm_network_security_group" "this" {
  name = "${var.common.project_name}-${var.name}-nsg"
  location = var.common.location
  resource_group_name = var.common.resource_group_name
  tags = var.common.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id = var.subnet_id
  network_security_group_id = azurerm_network_security_group.this.id
}
