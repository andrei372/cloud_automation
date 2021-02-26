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
variable "server_name" {
  description = "VM Hostname"
  type = string
}
variable "vm_user" {
  description = "Username for the VM"
  type = string
}
# not used we're generating a random string for now
/*
variable "vm_paswd" {
  description = "Password for the VM username"
  type = string
}
*/
variable "vnet_id" {
  description = "ID of the VNET where VM will be installed"
  type        = string
}
variable "subnet_id" {
  description = "ID of subnet where VM will be installed"
  type        = string
}
