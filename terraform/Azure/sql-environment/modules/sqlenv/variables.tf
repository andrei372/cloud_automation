#Variables used on the app-service.tf file
#############################
#     General Variables     #
#############################
# ==============================================================================================================
/*
variable "tenant_id" {
  description = "ID of subscription tenant"
  type = string
}
variable "subscription_id" {
  description = "ID of subscription"
  type = string
}
*/
variable "resource_group_name" {
  description = "Resource Group"
  type = string
}
variable "environment" {
  description = "Environment Type DEV|PROD"
  type = string
}

#############################
#     Storage Accounts      #
#############################
# ==============================================================================================================
variable "regions" {
  description = "single or array of regions to deploy too"
  //default = ["eastus", "westus"]
  default = []
}
variable "containers" {
  description = "Containers"
  type = set(string)
  default = []
}

#############################
#       SQL Server\DB       #
#############################
# ==============================================================================================================
variable "sql_servers"{
  description = "Specifies the SQL servers' name"
  default = []
}
variable "sql_version" {
  description = "Specifies the version of Azure SQL to use. Valid values are 5.6, 5.7, and 8.0"
  type        = string
}
variable "sql_server_admin_user" {
  description = "The Administrator Login for the Azure SQL Server"
  type        = string
}
/*
variable "sql_server_admin_passwd" {
  description = "The Administrator Login Password for the Azure SQL Server"
  default = ""
}
*/
variable "sql_databases" {
  description = "SQL Databases"
  default     = []
}
variable "sql_failover_group" {
  description = "SQL Failover Group name"
  type = string
}
variable "sql_firewall_rule" {
  description = "Contains a map of firewall rule details"
  type        = map(object({
    firewall_rule_name        = string
    start_ip_address          = string
    end_ip_address            = string
  }))
  default     = {}
}
