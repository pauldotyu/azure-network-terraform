####################################
# AZURE AUTOMATION FOR FIREWALL
####################################

resource "azurerm_automation_account" "network" {
  name                = "aa-${local.resource_name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
    # type = "SystemAssigned, UserAssigned"
    # identity_ids = [
    #   azurerm_user_assigned_identity.network.id
    # ]
  }

  tags = var.tags
}

resource "azurerm_automation_runbook" "afw_up" {
  name                    = "AzureFirewallUp"
  location                = azurerm_resource_group.network.location
  resource_group_name     = azurerm_resource_group.network.name
  automation_account_name = azurerm_automation_account.network.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is a runbook to allocate Azure Firewall"
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/pauldotyu/azure-automation-scripts/main/AzureFirewallUp.ps1"
  }
}

resource "azurerm_automation_runbook" "afw_down" {
  name                    = "AzureFirewallDown"
  location                = azurerm_resource_group.network.location
  resource_group_name     = azurerm_resource_group.network.name
  automation_account_name = azurerm_automation_account.network.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is a runbook to de-allocate Azure Firewall"
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/pauldotyu/azure-automation-scripts/main/AzureFirewallDown.ps1"
  }
}

resource "azurerm_automation_schedule" "afw_down" {
  name                    = "DailyShutdown"
  resource_group_name     = azurerm_resource_group.network.name
  automation_account_name = azurerm_automation_account.network.name
  frequency               = "Day"
  interval                = 1
  start_time              = timeadd(formatdate("YYYY-MM-DD'T'00:00:00-07:00", timestamp()), "22h") # 10pm today
  timezone                = "America/Los_Angeles"
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule
resource "azurerm_automation_job_schedule" "network" {
  automation_account_name = azurerm_automation_account.network.name
  resource_group_name     = azurerm_resource_group.network.name
  runbook_name            = azurerm_automation_runbook.afw_down.name
  schedule_name           = azurerm_automation_schedule.afw_down.name

  parameters = {
    fwname = "fw-${local.resource_name}"
    ipname = "fw-${local.resource_name}-ip"
    rgname = "rg-${local.resource_name}"
    vnname = "vn-${local.resource_name}"
  }
}

# resource "azurerm_user_assigned_identity" "network" {
#   resource_group_name = azurerm_resource_group.network.name
#   location            = azurerm_resource_group.network.location

#   name = "aa-${local.resource_name}-identity"
# }

resource "azurerm_role_assignment" "network" {
  scope                = azurerm_resource_group.network.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_automation_account.network.identity[0].principal_id
}