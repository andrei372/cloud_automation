#Variables used on the app-service.tf file
#############################
#     General Variables     #
#############################
# ==============================================================================================================
variable "tenant_id" {
  description = "tenant id"
  type = string
}
variable "subscription_id" {
  description = "Subscription ID"
  type = string
}
variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
}
variable "resource_group_id" {
  description = "Resource Group ID"
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
#       Log Analytics       #
#############################
# ==============================================================================================================
variable "log_analytics_workspace_name" {
    description = "Log Analytics WorkSpace name"
    default = "AKSLogAnalyticsWorkspaceName"
    type = string
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable "log_analytics_workspace_sku" {
    default = "PerGB2018"
}
#############################
#            AKS            #
#############################
# ==============================================================================================================
variable "node_count"{
  description = "number of nodes in the cluster"
  default = 2
  type = number
}
variable "nodepool_vm_size"{
  description = "Size of VMs in the pool"
  type = string
  default = "Standard_D2_v2"
}
variable "aks_name"{
  description = "aks cluster name"
  type = string
}
variable "dns_prefix"{
  description = "aks cluster DNS"
  type = string
}
variable "nodepool_subnet_id"{
  description = "Subnet ID to be used for the VMs in the node pool"
  type = string
}
variable "aks_node_username"{
  description = "aks node username"
  type = string
}
variable "ssh_public_key" {
  description = "location of public ssh key to push to nodes for admin access"
  default = "~/.ssh/id_rsa.pub"
  type = string
}
variable "network_docker_bridge_cidr"{
  description = "docker containers subnet in the AKS cluster"
  type = string
  default = "172.17.0.1/16"
}
variable "network_dns_service_ip"{
  description = "IP for DNS Service"
  type = string
}
variable "network_service_cidr"{
  description = "Subnet for AKS The Container Network Interface (CNI) Services"
  type = string
}


# features to enable\disable
# ==================================================================
variable "enable_auto_scaling" {
  default     = true
  description = "Enable autoscaling on the default node pool"
}
variable "enable_node_public_ip" {
  default     = false
  description = "Enable public IPs on the default node pool"
}
variable "enable_http_application_routing" {
  default = false
}
variable "enable_kube_dashboard" {
  default = true
}
variable "enable_aci_connector_linux" {
  default = false
}
variable "node_min_count"{
  description = "minimum node count for scaling"
  default = 1
  type = number
}
variable "node_max_count"{
  description = "maximum node count for scaling"
  default = 10
  type = number
}
