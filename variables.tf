variable "location" {
  type        = string
  description = "Location"
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
  type = string
}

variable "campus_address_range" {
  type = list(string)
}

variable "ipgroup_aadds" {
  type = list(string)
}

variable "ipgroup_wvd" {
  type = list(string)
}

variable "ipgroup_redcap" {
  type = list(string)
}

variable "ipgroup_devops" {
  type = list(string)
}

variable "ipgroup_devopsaci" {
  type = list(string)
}

variable "aadds_dns_servers" {
  type = list(string)
}

variable "vnet_peerings" {
  type = list(object({
    peering_name = string
    resource_id  = string
  }))
  description = "List of virtual networks that needs to peer to hub"
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
}

variable "vnet_address_prefixes" {
  type        = list(string)
  description = "Virtual network address space."
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
  description = "List of subnets"
}

variable "devops_akv_name" {
  type = string
}

variable "devops_rg_name" {
  type = string
}