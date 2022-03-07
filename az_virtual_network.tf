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

##########################################
# VIRTUAL NETWORK PEERING - DEVOPS
##########################################

provider "azurerm" {
  features {}
  alias           = "devops"
  subscription_id = var.devops_subscription_id
}

# Get resources by type, create vnet peerings
data "azurerm_resources" "devops_vnets" {
  provider = azurerm.devops
  type     = "Microsoft.Network/virtualNetworks"

  required_tags = {
    role = var.devops_role_tag_value
  }
}

# this will peer out to all the virtual networks tagged with a role of azops
resource "azurerm_virtual_network_peering" "devops_vnet_peer_out" {
  count                        = length(data.azurerm_resources.devops_vnets.resources)
  name                         = data.azurerm_resources.devops_vnets.resources[count.index].name
  remote_virtual_network_id    = data.azurerm_resources.devops_vnets.resources[count.index].id
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.network.name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# this will peer in from all the virtual networks tagged with the role of azops
# this also needs work. right now it is using variables when it should be using the data resource pulled from above;
# howver, the challenge is that the data resource does not return the resrouces' resource group which is required for peering
resource "azurerm_virtual_network_peering" "devops_vnet_peer_in" {
  provider                     = azurerm.devops
  count                        = length(data.azurerm_resources.devops_vnets.resources)
  name                         = azurerm_virtual_network.network.name
  remote_virtual_network_id    = azurerm_virtual_network.network.id
  resource_group_name          = split("/", data.azurerm_resources.devops_vnets.resources[count.index].id)[4]
  virtual_network_name         = data.azurerm_resources.devops_vnets.resources[count.index].name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}