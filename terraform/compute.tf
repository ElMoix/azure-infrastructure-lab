resource "azurerm_linux_virtual_machine" "main" {

  name                = local.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  size                = var.vm_size

  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = local.tags
}
