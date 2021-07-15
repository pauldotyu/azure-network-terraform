#######################################
# AZURE VIRTUAL NETWORK
#######################################

# These are subnets where NSGs should not be applied
locals {
  non_nsg_subnets = [
    "AADDSSubnet",
    "AzureBastionSubnet",
    "AzureFirewallSubnet",
    "AzureFirewallManagementSubnet",
    "GatewaySubnet"
  ]
}

resource "azurerm_network_security_group" "network" {
  name                = "nsg-${local.name}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  tags                = merge(var.tags, { "network-role" = "hubcity" })

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      access                                     = security_rule.value["access"]
      description                                = security_rule.value["description"]
      destination_address_prefix                 = security_rule.value["destination_address_prefix"]
      destination_address_prefixes               = security_rule.value["destination_address_prefixes"]
      destination_application_security_group_ids = security_rule.value["destination_application_security_group_ids"]
      destination_port_range                     = security_rule.value["destination_port_range"]
      destination_port_ranges                    = security_rule.value["destination_port_ranges"]
      direction                                  = security_rule.value["direction"]
      name                                       = security_rule.value["name"]
      priority                                   = security_rule.value["priority"]
      protocol                                   = security_rule.value["protocol"]
      source_address_prefix                      = security_rule.value["source_address_prefix"]
      source_address_prefixes                    = security_rule.value["source_address_prefixes"]
      source_application_security_group_ids      = security_rule.value["source_application_security_group_ids"]
      source_port_range                          = security_rule.value["source_port_range"]
      source_port_ranges                         = security_rule.value["source_port_ranges"]
    }
  }
}

resource "azurerm_virtual_network" "network" {
  name                = "vn-${local.name}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  address_space       = var.vnet_address_prefixes
  dns_servers         = var.aadds_dns_servers
  tags                = merge(var.tags, { "network-role" = "hubcity" })

  dynamic "subnet" {
    for_each = var.subnets
    content {
      name           = subnet.value["name"]
      address_prefix = subnet.value["address_prefix"]
      security_group = contains(toset(local.non_nsg_subnets), subnet.value["name"]) ? "" : azurerm_network_security_group.network.id
    }
  }
}

####################################
# AZURE VNET PEERINGS
####################################

resource "azurerm_virtual_network_peering" "network" {
  for_each                     = { for vp in var.vnet_peerings : vp.peering_name => vp }
  name                         = each.value["peering_name"]
  remote_virtual_network_id    = each.value["resource_id"]
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = "vn-${local.name}" # update module to include vnet in its ouput
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network.network
  ]
}
