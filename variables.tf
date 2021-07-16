variable "location" {
  type        = string
  description = "Location"
  default     = "westus2"

  validation {
    condition = can(index([
      "centralus",
      "eastus",
      "eastus2",
      "northcentralus",
      "southcentralus",
      "westcentralus",
      "westus",
      "westus2"
    ], var.location) >= 0)
    error_message = "The deployment location must be US regions."
  }
}

variable "tags" {
  description = "Resource tags"
  default = {
    "environment"        = "prod"
    "mission"            = "administrative"
    "protection-level"   = "p1"
    "availability-level" = "a1"
  }
}

variable "campus_gateway_address" {
  type    = string
  default = "52.179.213.99"
}

variable "campus_address_range" {
  type = list(string)
  default = [
    "10.101.0.0/16"
  ]
}

variable "ipgroup_aadds" {
  type = list(string)
  default = [
    "10.21.0.0/28"
  ]
}

variable "ipgroup_wvd" {
  type = list(string)
  default = [
    "10.21.17.0/24"
  ]
}

variable "ipgroup_redcap" {
  type = list(string)
  default = [
    "10.230.0.0/16"
  ]
}

variable "ipgroup_devops" {
  type = list(string)
  default = [
    "10.21.0.16/28"
  ]
}

variable "ipgroup_devopsaci" {
  type = list(string)
  default = [
    "10.21.0.32/28"
  ]
}

variable "aadds_dns_servers" {
  type    = list(string)
  default = ["10.21.0.4", "10.21.0.5"]
}

variable "vnet_peerings" {
  type = list(object({
    peering_name = string
    resource_id  = string
  }))
  description = "List of virtual networks that needs to peer to hub"
  default = [
    {
      peering_name = "to-identity"
      resource_id  = "/subscriptions/672f7b3e-5c19-454f-bb04-4843676bf396/resourceGroups/rg-aadds/providers/Microsoft.Network/virtualNetworks/vn-aadds"
    },
    {
      peering_name = "to-devops"
      resource_id  = "/subscriptions/672f7b3e-5c19-454f-bb04-4843676bf396/resourceGroups/rg-devops/providers/Microsoft.Network/virtualNetworks/vn-devops"
    },

    # {
    #   peering_name = "to-redcap-hub"
    #   resource_id  = "/subscriptions/781fa797-7ac8-4e52-ac22-2fc276d95ce3/resourceGroups/rg-redcap-0402/providers/Microsoft.Network/virtualNetworks/vn-redcap-hub"
    # }
  ]
}

variable "vpn_preshared_key" {
  type = string
}

variable "digicert_ssl_validation_key" {
  type = string
}

variable "nsg_rules" {
  type = list(object({
    access                                     = string
    description                                = string
    destination_address_prefix                 = string
    destination_address_prefixes               = list(string)
    destination_application_security_group_ids = list(string)
    destination_port_range                     = string
    destination_port_ranges                    = list(string)
    direction                                  = string
    name                                       = string
    priority                                   = number
    protocol                                   = string
    source_address_prefix                      = string
    source_address_prefixes                    = list(string)
    source_application_security_group_ids      = list(string)
    source_port_range                          = string
    source_port_ranges                         = list(string)
  }))
  description = "List of NSG rules"
  default     = []
}

variable "vnet_address_prefixes" {
  type        = list(string)
  description = "Virtual network address space."
  default     = ["10.21.1.0/24"]
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  description = "List of subnets"
  default = [
    {
      name           = "GatewaySubnet"
      address_prefix = "10.21.1.0/27"
    },
    {
      name           = "AzureBastionSubnet"
      address_prefix = "10.21.1.32/27"
    },
    {
      name           = "DevOpsSubnet"
      address_prefix = "10.21.1.64/27"
    },
    {
      name           = "ManagementSubnet"
      address_prefix = "10.21.1.96/27"
    },
    {
      name           = "AzureFirewallSubnet"
      address_prefix = "10.21.1.128/26"
    },
    # {
    #   name           = "AzureFirewallManagementSubnet"
    #   address_prefix = "10.21.1.192/26"
    # }
  ]
}

variable "devops_akv_name" {
  type = string
  default = "kvdevops1"
}

variable "devops_rg_name" {
  type= string
  default = "rg-devops"  
}