
# provider configured in provider.tf file

#############################
#  Resource Group Creation  #
#############################
# ============================================================================================================

resource "azurerm_resource_group" "vnet" {
  name     = "myenv-dev-vnet-rg"
  location = "East US"
}

resource "azurerm_resource_group" "kube" {
  name     = "myenv-dev-kube-rg"
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
  resource_group_name                                     = azurerm_resource_group.vnet.name

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

module "kube_network" {
  source                       = "./modules/vnet"
  environment                                             = "DEV"
  tenant_id                                               = ""        # not needed
  subscription_id                                         = ""        # not needed
  resource_group_name                                     = azurerm_resource_group.kube.name

  vnet_name                                               = "kube-net-vnet"
  vnet_address_space                                      = ["10.0.4.0/22"]
  regions                                                 = ["eastus","westus"]

  vnet_subnets                                            = [
                                                              {
                                                                name : "aks-subnet"
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
  vnet_1_rg                                              = azurerm_resource_group.vnet.name
  vnet_2_name                                            = module.kube_network.vnet_name
  vnet_2_id                                              = module.kube_network.vnet_id
  vnet_2_rg                                              = azurerm_resource_group.kube.name
  peering_name_1_to_2                                    = "Hub-To-Spoke1"
  peering_name_2_to_1                                    = "Spoke1-To-Hub"
}

# Firewall
# ================================
module "firewall" {
  source                                                 = "./modules/firewall"
  resource_group_name                                    = azurerm_resource_group.vnet.name
  regions                                                = ["eastus","westus"]
  pip_name                                               = "azureFirewalls-ip"
  fw_name                                                = "kubenetfw"
  subnet_id                                              = module.hub_network.subnet_ids["AzureFirewallSubnet"]
}

# Route Table
# =================================
# A user defined default route (0.0.0.0/0) from the AKS subnet to the firewall's private IP.
# we need to create the route table with the corresponding route and associate it to the AKS subnet.
module "routetable" {
  source                                                = "./modules/routetable"
  resource_group_name                                   = azurerm_resource_group.vnet.name
  regions                                               = ["eastus","westus"]
  rt_name                                               = "kubenetfw_fw_rt"
  r_name                                                = "kubenetfw_fw_r"
  firewall_private_ip                                   = module.firewall.firewall_private_ip                    # pick the value up from the firewall module; the private IP that gets auto assigned at creation
  subnet_id                                             = module.kube_network.subnet_ids["aks-subnet"]
}


# AKS CLUSTER
# ================================
module "aks" {
  source                       = "./modules/aks"

  environment                                             = "DEV"
  subscription_id                                         = ""
  tenant_id                                               = ""
  resource_group_name                                     = azurerm_resource_group.kube.name

  regions                                                 = ["eastus","westus"]
  aks_name                                                = "mydev-aks-cluster1"
  node_min_count                                          = 2                                # default is 1
  node_max_count                                          = 10                               # default is 10
  nodepool_vm_size                                         = "Standard_D2_v2"
  nodepool_subnet_id                                      = module.kube_network.subnet_ids["aks-subnet"]
  dns_prefix                                              = "mydevapp"
  aks_node_username                                       = "aksuser"
  network_docker_bridge_cidr                              = "172.17.0.1/16"                   # example     = "172.17.0.1/16"
  network_service_cidr                                    = "10.2.0.0/24"                     # example     = "10.2.0.0/24"
  network_dns_service_ip                                  = "10.2.0.10"                       # has to be within the subnet of the service_cidr

  resource_group_id                                        = azurerm_resource_group.vnet.id    # https://github.com/Azure/AKS/issues/1557
  #enable_auto_scaling                                     = default is true
  #enable_node_public_ip                                   = default is false
  #enable_http_application_routing                         = default is false
  #enable_kube_dashboard                                   = default is true
  #enable_aci_connector_linux                              = default is false


  # Becasuse of setting userDefinedRouting outbound type
  # AKS will expect to have a route table associated with its subnet
  # so it actually depends on the route table resource.
  depends_on = [module.routetable]
}

# JumpBox VM to manage AKS cluster
# ================================
module "jumpbox" {

  source                                                  = "./modules/jumpbox_vm"
  environment                                             = "DEV"
  vm_user                                                 = "jumpadmin"
  regions                                                 = ["eastus","westus"]
  resource_group_name                                     = azurerm_resource_group.vnet.name
  vnet_id                                                 = module.hub_network.vnet_id
  subnet_id                                               = module.hub_network.subnet_ids["jumpbox-subnet"]
                                                          # getting the Private DNS Zone’s name from the AKS cluster so the jump box sits inside the same one.
                                                          #It is generated automatically by Azure when the private AKS cluster is created
  dns_zone_name                                           = join(".", slice(split(".", module.aks.aks-private-fqdn), 1, length(split(".", module.aks.aks-private-fqdn))))
  dns_zone_resource_group_name                            = module.aks.aks-node-rg

  depends_on = [module.aks]
}
