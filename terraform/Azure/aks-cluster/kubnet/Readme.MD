# AKS (Azure Kubernetes) Terraform script 

The scripts will deploy an Azure AKS cluster within the default kubenet VNET

# Folder structure:

```bash
└───kubnet
    └───modules
        └───aks
```

# Deployment and prerequisites:

You will require to
-------------------
1. Create a resource group within your Azure subscription.  
		Variable "resource_group_name" in main.tf will be this value
2. A storage account and blob container will need to be created to store your TF state file
		The storage account, blob container you create and .tfstate file name of your chosing needs to be entered in the provider.tf file in this section
		
		```bash
		terraform {
			backend "azurerm" {
				resource_group_name      = "my-resource-group"
				storage_account_name     = "terraformstorageact"
				container_name           = "tfstate"
				key                      = "aks-cluster.tfstate"
			}
		}
		```

# Deployment procedure:
1. Install Azure CLIT 
	https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
	https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
	
2. Open an elevated command prompt \ terminal window and navigate to ...\Azure\aks-cluster\kubnet
3. type in "Az Login" and log into your Azure subscription
4. run "terraform init"
5. run "terraform plan"
6. run "terraform apply"
