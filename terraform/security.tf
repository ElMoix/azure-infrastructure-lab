resource "azurerm_network_security_group" "main" {
  name                = local.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.tags
}


resource "azurerm_network_security_rule" "ssh" {
  
  depends_on = [
    azurerm_network_security_group.main
  ]

  name      = "Allow-SSH"
  priority  = 1000
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}


resource "azurerm_network_security_rule" "http" {

  depends_on = [
    azurerm_network_security_group.main
  ]

  name      = "Allow-HTTP"
  priority  = 1010
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "80"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}


resource "azurerm_network_interface_security_group_association" "main" {

  network_interface_id = azurerm_network_interface.main.id

  network_security_group_id = azurerm_network_security_group.main.id
}
