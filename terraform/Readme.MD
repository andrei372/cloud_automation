# Terraform script for cloud deployments

Primary focus is on Azure

# Folder structure example:

```bash
└───terraform
    └───Azure
        ├───aks-cluster
        │   ├───azurenet
        │   │   └───modules
        │   │       ├───aks
        │   │       ├───firewall
        │   │       ├───jumpbox_vm
        │   │       ├───routetable
        │   │       ├───vnet
        │   │       └───vnet_peer
        │   └───kubnet
        │       └───modules
        │           └───aks
        ├───sql-environment
        │   └───modules
        │       ├───keyvault
        │       └───sqlenv
        ├───vm-availability-set
        │   └───modules
        │       ├───avail_set
        │       ├───linux_vm
        │       ├───vnet
        │       └───windows_vm
        ├───vm-environment
        │   └───modules
        │       ├───linux_vm
        │       ├───vnet
        │       └───windows_vm
        └───vnet-fw-environment
            └───modules
                ├───firewall
                ├───routetable
                ├───vnet
                └───vnet_peer
```

All terraform scripts follow this pattern:
------------------------------------------
1. The assumption is that you already have a RG (resource group) created within your subscription, that you will reference

2. main.tf calls out the modules needed and provides the variables values

3. they are designed to store the .tfstate file in a storage account blob container within your subscription
   the provider.tf file specifies the location and where you would need to configure it with your own values\names
   
	```bash
	terraform {
		backend "azurerm" {
			resource_group_name      = "my-resource-group"
			storage_account_name     = "terraformstorageact"
			container_name           = "tfstate"
			key                      = "deployment-name.tfstate"
		}
	}
	```

