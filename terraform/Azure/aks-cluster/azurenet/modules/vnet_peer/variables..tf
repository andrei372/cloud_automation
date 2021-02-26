#Variables used on the app-service.tf file
#############################
#     General Variables     #
#############################
# ==============================================================================================================

variable "vnet_1_rg" {
  description = "Resource Group for VNET 1"
  type = string
}
variable "vnet_2_rg" {
  description = "Resource Group for VNET 2"
  type = string
}
#############################
#    vNET Peer Variables    #
#############################
# ==============================================================================================================
variable "peering_name_1_to_2" {
  description = "Peering one way name"
  type = string
}
variable "peering_name_2_to_1" {
  description = "Peering the other way name"
  type = string
}
variable "vnet_1_name" {
  description = "Vnet 1 name"
  type = string
}
variable "vnet_1_id" {
  description = "Vnet 1 AZURE RM object ID"
  type = string
}


variable "vnet_2_name" {
  description = "Vnet 2 name"
  type = string
}
variable "vnet_2_id" {
  description = "Vnet 2 AZURE RM object ID"
  type = string
}
