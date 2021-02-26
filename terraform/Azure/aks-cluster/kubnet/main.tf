
# provider configured in provider.tf file

#############################
#  Resource Group Creation  #
#############################
# ============================================================================================================

resource "azurerm_resource_group" "kube" {
  name     = "myenv-dev-kube-rg"
  location = "East US"
}

#############################
#         Modules           #
#############################
# ==============================================================================================================


module "aks" {
  source                       = "../modules/aks"

  environment                                             = "Prod"                          # DEV | PROD
  subscription_id                                         = ""
  tenant_id                                               = ""
  resource_group_name                                     = azurerm_resource_group.kube.name


  regions                                                 = ["eastus","westus"]
  aks_name                                                = "my-aks-cluster1"
  #node_count                                              = 3
  node_min_count                                          = 2                                # default is 1
  node_max_count                                          = 10                               # default is 10
  dns_prefix                                              = "myapp"
  aks_node_username                                       = "aksuser"


  #enable_auto_scaling                                     = default is true
  #enable_node_public_ip                                   = default is false
  #enable_http_application_routing                         = default is false
  #enable_kube_dashboard                                   = default is true
  #enable_aci_connector_linux                              = default is false
}
