module "resource_group" {
  source = "./modules/resource_group"
  project_name = var.project_name
  location            = var.location
}

module "networking" {
  source = "./modules/networking"
  resource_group_name = module.resource_group.resource_group_name  
  project_name = var.project_name
  location            = var.location
}

# module "virtual_machine" {
#  source = "./modules/virtual_machine"
#
# resource_group_name = module.resource_group.resource_group_name
#  project_name = var.project_name
#  location            = var.location
#  subnet_id = module.networking.subnet_id
# }

module "sql_database" {
  source = "./modules/sql_database"
  resource_group_name = module.resource_group.resource_group_name
  project_name = var.project_name
  location            = var.location
  sql_server_name   = var.sql_server_name
  sql_database_name = var.sql_database_name
  admin_login    = var.sql_admin_login
  admin_password = var.sql_admin_password
}
