# azure-network-terraform

The intent of this repo is to build a demo hub virtual network for [Hub-spoke network topology in Azure](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=bicep) which consists of the following resources:

- Azure Virtual Network with appropriate Subnets, Network Security Groups, and Virtual Network Peerings
- Azure Firewall and Azure Firewall Policy which uses Azure IP Groups
- Azure Virtual Network Gateway
- Azure Bastion
- Azure DNS (public)
- Azure Automation

This repo uses Terraform Cloud for remote storage and remote runs. If you are using some other remote state solution, please update `backend.tf` accordingly.

To initialize your backend, you'll need to supply additional backend configs. This repo uses a partial backend configuration file named `config.remote.tfbackend` which is kept as a secret in the github repo. The config file looks like this:

```sh
workspaces { name = "<MY_TF_WORKSPACE_NAME>" }
hostname     = "app.terraform.io"
organization = "<MY_TF_ORGANIZATION_NAME>"
```

To initialize the backend, you can pass in the \*.tfbackend file at runtime like this;

```sh
terraform init --backend-config=config.remote.tfbackend
```

`main.tf` contains limited configuration. All Azure resources have been split out in files prefixed with `az_*` to make it a bit easier to find things.

`variables.tf` contains some default values so be sure to replace values accordingly. There are a few variables that do not contain default values since they are considered secrets so you'll need to pass in a value for `var.vpn_preshared_key` and possibly delete `var.digicert_ssl_validation_key` and it's corresponding which can be found in `az_dns.tf`.
