####################################
# AZURE DNS
####################################

# resource "azurerm_dns_zone" "work" {
#   name                = "contoso.work"
#   resource_group_name = azurerm_resource_group.network.name
#   tags                = var.tags
# }

# resource "azurerm_dns_txt_record" "work" {
#   name                = "@"
#   zone_name           = azurerm_dns_zone.work.name
#   resource_group_name = azurerm_resource_group.network.name
#   ttl                 = 3600

#   # txt record used for digicert ssl validation
#   record {
#     value = var.digicert_ssl_validation_key
#   }

#   tags = var.tags
# }

# resource "azurerm_dns_cname_record" "redcapsample1" {
#   name                = "redcapsample1"
#   zone_name           = azurerm_dns_zone.work.name
#   resource_group_name = azurerm_resource_group.network.name
#   ttl                 = 300
#   record              = "contosoredcap.azurefd.net"
# }

# resource "azurerm_private_dns_zone" "blob" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = azurerm_resource_group.network.name
#   tags                = var.tags
# }

# resource "azurerm_private_dns_zone" "mysql" {
#   name                = "privatelink.mysql.database.azure.com"
#   resource_group_name = azurerm_resource_group.network.name
#   tags                = var.tags
# }

# resource "azurerm_private_dns_zone" "keyvault" {
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = azurerm_resource_group.network.name
#   tags                = var.tags
# }
