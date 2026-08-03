project_name    = "elmoix-dev"
subscription_id = "4a16cab3-f9ab-4ad8-a54d-f4b285619fd2"
location        = "France Central"

sql_server_name    = "azurelab-elmoix-dev"
sql_database_name  = "azurelabdb"
sql_admin_login    = "azureadmin"
sql_admin_password = "$uper$ecurePass@98"

deploy_vm  = false
deploy_sql = false


virtual_networks = {
  hub = {
    address_space = [
      "10.0.0.0/16"
    ]
  }

  spoke = {
    address_space = [
      "10.1.0.0/16"
    ]
  }
}

subnets = {
  frontend = {
    virtual_network = "hub"
    address_prefix = "10.0.1.0/24"
  }

  backend = {
    virtual_network = "hub"
    address_prefix = "10.0.2.0/24"
  }

  database = {
    virtual_network = "spoke"
    address_prefix = "10.1.1.0/24"
  }
}

nsgs = {
  frontend = {
    subnet = "frontend"
  }

  backend = {
    subnet = "backend"
  }

  database = {
    subnet = "database"
  }
}
