# azure-network-terraform

The intent of this repo is to build a demo hub virtual network which contains the following resources:

- Virtual Network with appropriate Subnets, Network Security Groups, and Virtual Network Peerings
- Azure Firewall and Azure Firewall Policy which uses Azure IP Groups
- Azure Virtual Network Gateway
- Azure Bastion
- Azure DNS (public)
- Azure Automation

This repo uses Azure Storage for storing remote state files. If you are using some other remote state solution, please update `backend.tf` accordingly.

To initialize your Azure storage backend, you'll need to supply additional backend configs. Here is an example:

```sh
terraform init \
  -backend-config="resource_group_name=<YOUR_RESOURCE_GROUP_NAME>" \
  -backend-config="storage_account_name=<YOUR_STORAGE_ACCOUNT_NAME>" \
  -backend-config="container_name=<YOUR_CONTAINER_NAME>" \
  -backend-config="key=terraform.tfstate"
```

`main.tf` contains limited configuration. All Azure resources have been split out in files prefixed with `az_*` to make it a bit easier to find things.

`variables.tf` contains some default values so be sure to replace values accordingly. There are a few variables that do not contain default values since they are considered secrets so you'll need to pass in a value for `var.vpn_preshared_key` and possibly delete `var.digicert_ssl_validation_key` and it's corresponding which can be found in `az_dns.tf`.
