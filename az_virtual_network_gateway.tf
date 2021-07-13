#######################################
# AZURE VIRTUAL NETWORK GATEWAY
#######################################

resource "azurerm_public_ip" "vng" {
  name                = "vng-${local.name}-ip"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "network" {
  name                = "vng-${local.name}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw1AZ"
  tags                = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vng.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = element(azurerm_virtual_network.network.subnet.*.id, index(azurerm_virtual_network.network.subnet.*.name, "GatewaySubnet"))
  }

  depends_on = [
    azurerm_public_ip.vng
  ]
}

resource "azurerm_local_network_gateway" "campus" {
  name                = "campus-network"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  gateway_address     = var.campus_gateway_address
  address_space       = var.campus_address_range
}

resource "azurerm_virtual_network_gateway_connection" "campus" {
  name                               = "campus-connection"
  location                           = azurerm_resource_group.network.location
  resource_group_name                = azurerm_resource_group.network.name
  type                               = "IPsec"
  connection_protocol                = "IKEv2"
  dpd_timeout_seconds                = 45
  enable_bgp                         = false
  express_route_gateway_bypass       = false
  local_azure_ip_address_enabled     = false
  routing_weight                     = 0
  use_policy_based_traffic_selectors = false
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.network.id
  local_network_gateway_id           = azurerm_local_network_gateway.campus.id

  shared_key = var.vpn_preshared_key
}