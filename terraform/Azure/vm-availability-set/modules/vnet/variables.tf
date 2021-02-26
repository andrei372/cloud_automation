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
#      vNET Variables       #
#############################
# ==============================================================================================================
variable "vnet_name" {
  description = "vNET name in Azure"
  type = string
}
variable "vnet_address_space" {
  description = "vNET address space subnet"
  type = list(string)
}
variable "vnet_subnets" {
  description = "vNET subnets configuration"
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
}
