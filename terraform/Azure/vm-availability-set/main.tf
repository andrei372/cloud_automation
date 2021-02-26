
# provider configured in provider.tf file

#############################
#  Resource Group Creation  #
#############################
# ============================================================================================================

resource "azurerm_resource_group" "vnet" {
  name     = "myenv-rg"
  location = "East US"
}

#############################
#         Modules           #
#############################
# ==============================================================================================================

# CREATE THE VNET
# ================================
module "hub_network" {
  source                       = "./modules/vnet"
  environment                                             = "DEV"
  resource_group_name                                     = azurerm_resource_group.vnet.name

  vnet_name                                               = "hub-net-vnet"
  vnet_address_space                                      = ["10.0.0.0/22"]
  regions                                                 = ["eastus","westus"]

  vnet_subnets                                            = [
                                                              {
                                                                # if you ever desire to be able to put an Azure firewall on your vnet
                                                                name : "AzureFirewallSubnet"
                                                                address_prefixes : ["10.0.0.0/24"]
                                                              },
                                                              {
                                                                name : "vm-subnet"
                                                                address_prefixes : ["10.0.1.0/24"]
                                                              }
                                                            ]
}

# VM Creation
# ================================

# Windows VM
# --------------------------------
module "linux_availability_set" {

  source                      = "./modules/avail_set"
  environment                                             = "DEV"
  av_set_name                                             = "windows-set1"
  regions                                                 = ["eastus","westus"]
  resource_group_name                                     = azurerm_resource_group.vnet.name
}

module "windows-vm" {

  source                                                  = "./modules/windows_vm"
  environment                                             = "DEV"
  server_name                                             = "windows-vm1"
  vm_user                                                 = "vmadmin"
  regions                                                 = ["eastus","westus"]
  resource_group_name                                     = azurerm_resource_group.vnet.name
  vnet_id                                                 = module.hub_network.vnet_id
  subnet_id                                               = module.hub_network.subnet_ids["vm-subnet"]
  availability_set_id                                     = module.windows_availability_set.availability_set_id
}

# Linux VM
# --------------------------------
module "windows_availability_set" {

  source                      = "./modules/avail_set"
  environment                                             = "DEV"
  av_set_name                                             = "linux-set1"
  regions                                                 = ["eastus","westus"]
  resource_group_name                                     = azurerm_resource_group.vnet.name
}

module "linux-vm" {

  source                                                  = "./modules/linux_vm"
  environment                                             = "DEV"
  server_name                                             = "linux-vm1"
  vm_user                                                 = "vmadmin"
  regions                                                 = ["eastus","westus"]
  resource_group_name                                     = azurerm_resource_group.vnet.name
  vnet_id                                                 = module.hub_network.vnet_id
  subnet_id                                               = module.hub_network.subnet_ids["vm-subnet"]
  availability_set_id                                     = module.linux_availability_set.availability_set_id
}
