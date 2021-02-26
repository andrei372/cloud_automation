
# provider configured in provider.tf file

#############################
#  Resource Group Creation  #
#############################
# ============================================================================================================

resource "azurerm_resource_group" "sqlenv" {
  name     = "myenv-rg"
  location = "East US"
}

#############################
#         Modules           #
#############################
# ==============================================================================================================

module "sqlenv" {
  source                       = "./modules/sqlenv"

  environment                                             = "DEV"
  /*
  tenant_id                                               = ""
  subscription_id                                         = ""
  */
  resource_group_name                                     = azurerm_resource_group.sqlenv.name


  regions                                                 = ["eastus","westus"]
  containers                                              = ["test1","test2","test3","test4","test5"]
  sql_servers                                             = ["myenv-eaus-sqlsrv1","myenv-eaus-sqlsrv2"]
  sql_server_admin_user                                   = "sqladmin"
  #sql_server_admin_passwd                                 = ""
  sql_version                                             = "12.0"
  sql_databases                                           = ["db1","db2","db3"]
  sql_failover_group                                      = "myenv-zeasu-sqlfg"

  # can add many more rules as needed in the format below
  sql_firewall_rule                                       = {
                                                            "fw_rule1" = {
                                                              firewall_rule_name        = "allow_WAN_IN_subnet1"
                                                              start_ip_address          = "1.1.1.1"
                                                              end_ip_address            = "1.1.1.1"
                                                            },
                                                            "fw_rule2" = {
                                                              firewall_rule_name        = "allow__WAN_IN_subnet2"
                                                              start_ip_address          = "2.2.2.2"
                                                              end_ip_address            = "2.2.2.2"
                                                            }
                                                          }
}

module "keyvault" {
  source                       = "./modules/keyvault"
  environment                                             = "DEV"

  resource_group_name                                     = azurerm_resource_group.sqlenv.name

  regions                                                 = ["eastus","westus"]
  keyvaultname                                            = "myenv-easu-kvtest"
  enabled_for_deployment                                  = true
  enabled_for_template_deployment                         = true
  /*
  secrets                                                 = {
                                                              "appusername" = "demouser"
                                                              "apptoken"    = "demotoken"
                                                            }
  */
}
