
# provider configured in provider.tf file

#############################
#  Resource Group Creation  #
#############################
# ============================================================================================================

resource "azurerm_resource_group" "hub" {
  name     = "myenv-hub-rg"
  location = "East US"
}

resource "azurerm_resource_group" "spoke" {
  name     = "myenv-spoke-rg"
  location = "East US"
}

//data "azurerm_client_config" "current" {}

#############################
#         Modules           #
#############################
# ==============================================================================================================

# CREATE THE VNETS
# ================================
module "hub_network" {
  source                       = "./modules/vnet"
  environment                                             = "DEV"
  tenant_id                                               = ""        # not needed
  subscription_id                                         = ""        # not needed
  resource_group_name                                     = azurerm_resource_group.hub.name

  vnet_name                                               = "hub-net-vnet"
  vnet_address_space                                      = ["10.0.0.0/22"]
  regions                                                 = ["eastus","westus"]

  vnet_subnets                                            = [
                                                              {
                                                                name : "AzureFirewallSubnet"
                                                                address_prefixes : ["10.0.0.0/24"]
                                                              },
                                                              {
                                                                name : "jumpbox-subnet"
                                                                address_prefixes : ["10.0.1.0/24"]
                                                              }
                                                            ]
}

module "spoke_network" {
  source                       = "./modules/vnet"
  environment                                             = "DEV"
  tenant_id                                               = ""        # not needed
  subscription_id                                         = ""        # not needed
  resource_group_name                                     = azurerm_resource_group.spoke.name

  vnet_name                                               = "spoke-net-vnet"
  vnet_address_space                                      = ["10.0.4.0/22"]
  regions                                                 = ["eastus","westus"]

  vnet_subnets                                            = [
                                                              {
                                                                name : "app-subnet"
                                                                address_prefixes : ["10.0.5.0/24"]
                                                              }
                                                            ]
}

# Peer the VNETs
# ================================
module "vnet_peering" {
  source              = "./modules/vnet_peer"
  vnet_1_name                                            = module.hub_network.vnet_name
  vnet_1_id                                              = module.hub_network.vnet_id
  vnet_1_rg                                              = azurerm_resource_group.hub.name
  vnet_2_name                                            = module.spoke_network.vnet_name
  vnet_2_id                                              = module.spoke_network.vnet_id
  vnet_2_rg                                              = azurerm_resource_group.spoke.name
  peering_name_1_to_2                                    = "Hub-To-Spoke1"
  peering_name_2_to_1                                    = "Spoke1-To-Hub"
}

# Firewall
# ================================
module "firewall" {
  source                                                 = "./modules/firewall"
  resource_group_name                                    = azurerm_resource_group.hub.name
  regions                                                = ["eastus","westus"]
  pip_name                                               = "azureFirewalls-ip"
  fw_name                                                = "spokenetfw"
  subnet_id                                              = module.hub_network.subnet_ids["AzureFirewallSubnet"]
}

# Route Table
# =================================
# A user defined default route (0.0.0.0/0) from the Spoke subnet to the firewall's private IP.
# we need to create the route table with the corresponding route and associate it to the APP subnet.
module "routetable" {
  source                                                = "./modules/routetable"
  resource_group_name                                   = azurerm_resource_group.hub.name
  regions                                               = ["eastus","westus"]
  rt_name                                               = "spokenetfw_fw_rt"
  r_name                                                = "spokenetfw_fw_r"
  firewall_private_ip                                   = module.firewall.firewall_private_ip                     # pick the value up from the firewall module; the private IP that gets auto assigned at creation
  subnet_id                                             = module.spoke_network.subnet_ids["app-subnet"]
}
