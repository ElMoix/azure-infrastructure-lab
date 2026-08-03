module "resource_group" {
  source       = "../../modules/resource_group"
  common = local.common  
}

module "virtual_network" {
  source = "../../modules/virtual_network"
  for_each = var.virtual_networks

  common = local.common
  config = each.value
  name = each.key
}

module "subnet" {
  source = "../../modules/subnet"
  for_each = var.subnets

  common = local.common
  name = each.key
  virtual_network_name = module.virtual_network[
    each.value.virtual_network
  ].name
  config = each.value
}

module "nsg" {
  source = "../../modules/nsg"
  for_each = var.nsgs
  
  common = local.common
  name = each.key
  subnet_id = module.subnet[
    each.value.subnet
  ].id
  config = each.value
}
