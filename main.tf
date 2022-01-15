provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

resource "random_pet" "p" {
  length    = 1
  separator = ""
}

locals {
  name = format("%s%s", "network", random_pet.p.id)
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = var.tags
}