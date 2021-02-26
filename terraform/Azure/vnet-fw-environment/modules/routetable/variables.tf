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
#   Route table variables   #
#############################
# ==============================================================================================================

variable "rt_name" {
  description = "Route Table Name"
  type = string
}
variable "r_name" {
  description = "Route Name"
  type = string
}
variable "firewall_private_ip" {
  description = "Firewall private | internal IP"
  type = string
}
variable "subnet_id" {
  description = "ID of subnet associated with the routetable"
  type = string
}
