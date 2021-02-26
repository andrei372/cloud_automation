# Isolated Kubernetes Cluster Environment

Environment creates our own vNET Azure Firewall and Jumpbox and isolates the AKS cluster network behind the Firewall

The scripts will deploy:
	- 2 vNETs
			- 1 vNET for jump server subnet and AZ firewall subnet
			- 1 vNET for AKS cluster
			- vNET Peering between these 2 vNETs
	- 1 AZ Firewall
			- 1 routetable to route all traffic via AZ firewall
	- 1 AKS scalable cluster with 3 nodes min | 10 nodes max 



# Folder structure:

```bash
├───aks-cluster
│   ├───azurenet
│   │   └───modules
│   │       ├───aks
│   │       ├───firewall
│   │       ├───jumpbox_vm
│   │       ├───routetable
│   │       ├───vnet
│   │       └───vnet_peer
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

2. Open an elevated command prompt \ terminal window and navigate to ...\Azure\aks-cluster\azurenet
3. type in "Az Login" and log into your Azure subscription
4. AKS Linux nodes and jumpbox_vm require a public SSH key to use for authentication

		- SSH Key must be openssh key (generated via ssh-keygen commant) - not putty RSA
		
		- Scripts look at this location locally to ingest public key and pass over to nodes and jump server "~/.ssh/id_rsa.pub"
		
		- Jumpbox vm provision module looks at this location locally to ingest private key "~/.ssh/id_rsa" to authenticate and remote execute commands to prep VM
4. run "terraform init"
5. run "terraform plan"
6. run "terraform apply"
