####################################
# AZURE FIREWALL
####################################

resource "azurerm_firewall_policy" "network" {
  name                     = "fw-policy"
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  sku                      = "Premium"
  threat_intelligence_mode = "Alert"
  tags                     = var.tags

  dns {
    servers       = var.aadds_dns_servers
    proxy_enabled = true
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "network" {
  name               = "ContosoRules"
  firewall_policy_id = azurerm_firewall_policy.network.id
  priority           = 400

  # nat_rule_collection {
  #   name     = "natrules"
  #   priority = 300
  #   action   = "Dnat"
  #   rule {
  #     name                = "nat_rule_collection1_rule1"
  #     protocols           = ["TCP", "UDP"]
  #     source_addresses    = ["10.0.0.1", "10.0.0.2"]
  #     destination_address = "192.168.1.1"
  #     destination_ports   = ["80", "1000-2000"]
  #     translated_address  = "192.168.0.1"
  #     translated_port     = "8080"
  #   }
  # }

  application_rule_collection {
    name     = "ApplicationAllowRules"
    action   = "Allow"
    priority = 500

    rule {
      name = "AllowedSites"

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      source_ip_groups = [
        azurerm_ip_group.redcap.id
      ]

      destination_fqdns = [
        "*.microsoft.com",
        "*.msftauth.net",
        "*.digicert.com",
        "*.office.com",
        "*.qualys.com",
        "raw.githubusercontent.com",
      ]
    }

    rule {
      name = "AllowedAzure"

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      source_ip_groups = [
        azurerm_ip_group.redcap.id
      ]

      destination_fqdn_tags = [
        "AppServiceEnvironment",
        "AzureBackup",
        "AzureKubernetesService",
        "HDInsight",
        "MicrosoftActiveProtectionService",
        "WindowsDiagnostics",
        "WindowsUpdate",
        "WindowsVirtualDesktop"
      ]
    }
  }

  network_rule_collection {
    action   = "Allow"
    name     = "NetworkAllowRules"
    priority = 400

    rule {
      name = "AllowMicrosoftStuff"
      source_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_addresses = [
        "ApiManagement",
        "AzureActiveDirectory",
        "AzureMonitor",
        "BatchNodeManagement",
        "AzureActiveDirectoryDomainServices",
        "ServiceFabric",
        "SqlManagement",
        "AzureFrontDoor.Backend",
        "AzurePlatformDNS",
        "AzurePlatformIMDS",
        "AzurePlatformLKM",
        "ActionGroup",
        "AppService",
        "AppServiceManagement",
        "ApplicationInsightsAvailability",
        "AzureAdvancedThreatProtection",
        "AzureBackup",
        "AzureBotService",
        "AzureCloud",
        "AzureCognitiveSearch",
        "AzureConnectors",
        "AzureContainerRegistry",
        "AzureCosmosDB",
        "AzureDataExplorerManagement",
        "AzureDatabricks",
        "AzureDataLake",
        "AzureDevSpaces",
        "AzureEventGrid",
        "AzureFrontDoor.FirstParty",
        "AzureFrontDoor.Frontend",
        "AzureInformationProtection",
        "AzureIoTHub",
        "AzureKeyVault",
        "AzureMachineLearning",
        "AzureOpenDatasets",
        "AzurePortal",
        "AzureResourceManager",
        "AzureSignalR",
        "AzureSiteRecovery",
        "AzureTrafficManager",
        "CognitiveServicesManagement",
        "DataFactory",
        "DataFactoryManagement",
        "Dynamics365ForMarketingEmail",
        "EventHub",
        "GuestAndHybridManagement",
        "HDInsight",
        "LogicApps",
        "LogicAppsManagement",
        "MicrosoftCloudAppSecurity",
        "WindowsVirtualDesktop",
        "Storage",
        "Sql",
        "ServiceBus",
        "PowerQueryOnline",
        "MicrosoftContainerRegistry",
        "AppService.WestUS2",
        "AzureCloud.WestUS2",
        "AzureConnectors.WestUS2",
        "AzureContainerRegistry.WestUS2",
        "AzureCosmosDB.WestUS2",
        "EventHub.WestUS2",
        "AzureKeyVault.WestUS2",
        "Sql.WestUS2",
        "ServiceBus.WestUS2",
        "Storage.WestUS2",
        "Dynamics365ForMarketingEmail.WestUS2",
        "HDInsight.WestUS2",
        "MicrosoftContainerRegistry.WestUS2"
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "aadds-to-redcap"
      source_ip_groups = [
        azurerm_ip_group.aadds.id
      ]
      destination_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "redcap-to-aadds"
      source_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ip_groups = [
        azurerm_ip_group.aadds.id
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "devops-to-redcap"
      source_ip_groups = [
        azurerm_ip_group.devops.id
      ]
      destination_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "redcap-to-devops"
      source_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ip_groups = [
        azurerm_ip_group.devops.id
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "devopsaci-to-redcap"
      source_ip_groups = [
        azurerm_ip_group.devopsaci.id
      ]
      destination_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }

    rule {
      name = "redcap-to-devopsaci"
      source_ip_groups = [
        azurerm_ip_group.redcap.id,
      ]
      destination_ip_groups = [
        azurerm_ip_group.devopsaci.id
      ]
      destination_ports = ["*"]
      protocols         = ["Any"]
    }
  }

  depends_on = [
    azurerm_firewall_policy.network,
    azurerm_ip_group.aadds,
    azurerm_ip_group.devops,
    azurerm_ip_group.redcap,
    azurerm_ip_group.wvd
  ]
}

resource "azurerm_public_ip" "fw" {
  name                = "fw-${local.resource_name}-ip"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "fw_mgmt" {
  name                = "fw-mgmt-${local.resource_name}-ip"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "network" {
  name                = "fw-${local.resource_name}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  threat_intel_mode   = "Alert"
  firewall_policy_id  = azurerm_firewall_policy.network.id
  tags                = var.tags

  ip_configuration {
    name                 = "AzureFirewallIpConfiguration0"
    public_ip_address_id = azurerm_public_ip.fw.id
    subnet_id            = element(azurerm_virtual_network.network.subnet.*.id, index(azurerm_virtual_network.network.subnet.*.name, "AzureFirewallSubnet"))
  }

  # management_ip_configuration {
  #   name                 = "mgmtipconfig1"
  #   public_ip_address_id = azurerm_public_ip.fw_mgmt.id
  #   subnet_id            = element(azurerm_virtual_network.network.subnet.*.id, index(azurerm_virtual_network.network.subnet.*.name, "AzureFirewallManagementSubnet"))
  # }

  depends_on = [
    azurerm_firewall_policy.network,
    azurerm_firewall_policy_rule_collection_group.network
  ]
}