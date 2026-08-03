resource "azurerm_resource_group" "this" {
  name = "${var.common.project_name}-rg"
  location = var.common.location
}
