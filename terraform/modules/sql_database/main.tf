resource "azurerm_mssql_server" "this" {
  name                = "${var.project_name}-sql"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"

  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password

  minimum_tls_version = "1.2"

  tags = {
    Environment = "Lab"
  }
}

resource "azurerm_mssql_database" "this" {
  name      = "${var.project_name}-db"
  server_id = azurerm_mssql_server.this.id

  sku_name = "Basic"

  tags = {
    Environment = "Lab"
  }
}
