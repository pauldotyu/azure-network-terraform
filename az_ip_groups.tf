#####################################
# AZURE IP GROUPS
####################################

resource "azurerm_ip_group" "aadds" {
  name                = "ipg-aadds"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  cidrs               = var.ipgroup_aadds
  tags                = var.tags
}

resource "azurerm_ip_group" "wvd" {
  name                = "ipg-wvd"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  cidrs               = var.ipgroup_wvd
  tags                = var.tags
}

resource "azurerm_ip_group" "redcap" {
  name                = "ipg-redcap"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  cidrs               = var.ipgroup_redcap
  tags                = var.tags
}

resource "azurerm_ip_group" "devops" {
  name                = "ipg-devops"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  cidrs               = var.ipgroup_devops
  tags                = var.tags
}

resource "azurerm_ip_group" "devopsaci" {
  name                = "ipg-devopsaci"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  cidrs               = var.ipgroup_devopsaci
  tags                = var.tags
}
