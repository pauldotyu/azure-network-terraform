#######################################
# AZURE VIRTUAL NETWORK
#######################################

# These are subnets where NSGs should not be applied
locals {
  non_nsg_subnets = [
    "networkSubnet",
    "AzureBastionSubnet",
    "AzureFirewallSubnet",
    "AzureFirewallManagementSubnet",
    "GatewaySubnet"
  ]
}

resource "azurerm_network_security_group" "network" {
  name                = "nsg-${local.resource_name}"
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
  name                = "vn-${local.resource_name}"
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

# Get resources by type, create hub vnet peerings
# Rather than explicity call out the virtual network to peer,
# This data source will pull a list of virtual network  by querying
# the network-dependency tag. If the tag is "hubcity" then it will be peered
# to the virtual network created within this deployment.
data "azurerm_resources" "vnets" {
  type = "Microsoft.Network/virtualNetworks"

  required_tags = {
    network-dependency = "hubcity"
  }
}

resource "azurerm_virtual_network_peering" "network" {
  count                        = length(data.azurerm_resources.vnets.resources)
  name                         = "${azurerm_virtual_network.network.name}-to-${data.azurerm_resources.vnets.resources[count.index].name}"
  remote_virtual_network_id    = data.azurerm_resources.vnets.resources[count.index].id
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.network.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}