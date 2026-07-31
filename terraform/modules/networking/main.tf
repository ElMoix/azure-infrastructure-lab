resource "azurerm_virtual_network" "this" {
  name = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = [
    "10.0.0.0/16"
  ]
}

resource "azurerm_subnet" "this" {
  name = "${var.project_name}-subnet"  
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}

resource "azurerm_network_security_group" "this" {
  name = "${var.project_name}-nsg"  
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name      = "AllowSSH"
  priority  = 1000
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
