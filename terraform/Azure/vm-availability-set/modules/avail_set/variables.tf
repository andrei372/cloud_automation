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
#      VM Variables       #
#############################
# ==============================================================================================================
variable "av_set_name" {
  description = "Availability Set Name"
  type = string
}
