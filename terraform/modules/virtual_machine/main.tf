resource "azurerm_public_ip" "this" {
  name                = "${var.project_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_network_interface" "this" {
  name                = "${var.project_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name = "internal"

    subnet_id = var.subnet_id

    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "${var.project_name}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  size = var.vm_size

  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username = var.admin_username

    public_key = file(var.public_key_path)
  }

  os_disk {

    caching = "ReadWrite"

    storage_account_type = "Standard_LRS"

  }

  source_image_reference {

    publisher = "Canonical"

    offer = "ubuntu-24_04-lts"

    sku = "server"

    version = "latest"

  }

}
