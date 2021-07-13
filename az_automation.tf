####################################
# AZURE AUTOMATION FOR FIREWALL 
####################################

resource "azurerm_automation_account" "network" {
  name                = "aa-${local.name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku_name            = "Basic"
  tags                = var.tags
}

data "azurerm_key_vault" "network" {
  name                = var.devops_akv_name
  resource_group_name = var.devops_rg_name
}

data "azurerm_key_vault_certificate" "network" {
  name         = "starcontosowork"
  key_vault_id = data.azurerm_key_vault.network.id
}

resource "azurerm_automation_certificate" "network" {
  name                    = "aa-${local.name}-cert"
  resource_group_name     = azurerm_resource_group.network.name
  automation_account_name = azurerm_automation_account.network.name
  base64                  = data.azurerm_key_vault_certificate.network.certificate_data_base64
}

resource "azurerm_automation_connection_certificate" "network" {
  name                        = "AzureRunAsConnection"
  description                 = "This connection contains information about the service principal that was automatically created for this automation account. For details on this service principal and its certificate, or to recreate them, go to this account’s Settings. For example usage, see the tutorial runbook in this account."
  resource_group_name         = azurerm_resource_group.network.name
  automation_account_name     = azurerm_automation_account.network.name
  automation_certificate_name = azurerm_automation_certificate.network.name
  subscription_id             = data.azurerm_client_config.current.subscription_id
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
    fwname = "fw-${local.name}"
    ipname = "fw-${local.name}-ip"
    rgname = "rg-${local.name}"
    vnname = "vn-${local.name}"
  }
}