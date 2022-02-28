
resource "azurerm_virtual_network_peering" "network" {
  for_each                     = { for vp in var.vnet_peerings : vp.peering_name => vp }
  name                         = each.value["peering_name"]
  remote_virtual_network_id    = each.value["resource_id"]
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.network.name # update module to include vnet in its ouput
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}