#Variables used on the app-service.tf file
#############################
#     General Variables     #
#############################
# ==============================================================================================================

variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
}
variable "regions" {
  description = "single or array of regions to deploy too"
  //default = ["eastus", "westus"]
  default = []
}
#############################
#    Firewall variables     #
#############################
# ==============================================================================================================

variable "pip_name" {
  description = "Firewall Public IP Name"
  type = string
}

variable "fw_name" {
  description = "Firewall Name"
  type = string
}
variable "subnet_id" {
  description = "Subnet ID for the firewall"
  type = string
}
