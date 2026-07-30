resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = var.vnet_address_space
  tags = local.tags
}


resource "azurerm_subnet" "main" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = var.subnet_address_prefixes
}


resource "azurerm_public_ip" "main" {
  name                = local.public_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"

  sku = "Standard"

  tags = local.tags
}


resource "azurerm_network_interface" "main" {

  depends_on = [
    azurerm_subnet.main,
    azurerm_public_ip.main
  ]

  name                = local.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {

    name = "internal"

    subnet_id = azurerm_subnet.main.id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = local.tags
}
