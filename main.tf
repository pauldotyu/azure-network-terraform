provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "random_pet" "p" {
  length    = 1
  separator = ""
}

locals {
  resource_name = format("%s%s", "netops", random_pet.p.id)
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.resource_name}"
  location = var.location
  tags     = var.tags
}