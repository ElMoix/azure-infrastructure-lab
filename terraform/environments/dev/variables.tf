variable "subscription_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_admin_login" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
}

variable "deploy_vm" {
  type    = bool
  default = false
}

variable "deploy_sql" {
  type    = bool
  default = false
}
