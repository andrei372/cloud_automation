#Variables used on the app-service.tf file
#############################
#     General Variables     #
#############################
# ==============================================================================================================

variable "resource_group_name" {
  description = "Resource Group"
  type = string
}
variable "environment" {
  description = "Environment Type DEV|PROD"
  type = string
}
variable "regions" {
  description = "single or array of regions to deploy too"
  //default = ["eastus", "westus"]
  default = []
}

#############################
#         Key Vault         #
#############################
# ==============================================================================================================
variable "keyvaultname"{
  description = "Key Vaule Name"
  type = string
}
/*
variable "secrets" {
  type        = map
  description = "Map of secrets and values"
  default     = {}
}
*/
variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}
variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}
