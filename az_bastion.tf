#####################################
# AZURE BASTION + JUMP VM
#####################################

resource "azurerm_public_ip" "bh" {
  name                = "bh-${local.name}-ip"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "network" {
  name                = "bh-${local.name}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  tags                = var.tags

  ip_configuration {
    name                 = "IpConf"
    subnet_id            = element(azurerm_virtual_network.vn.subnet.*.id, index(azurerm_virtual_network.vn.subnet.*.name, "AzureBastionSubnet"))
    public_ip_address_id = azurerm_public_ip.bh.id
  }
}
