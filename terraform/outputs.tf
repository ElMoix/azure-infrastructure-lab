output "resource_group_name" {
  description = "Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "virtual_machine_name" {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "public_ip_address" {
  description = "Public IP Address"

  value = azurerm_public_ip.main.ip_address
}

output "ssh_connection" {
  description = "SSH command"

  value = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}
