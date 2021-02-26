#############################
#     Storage Accounts      #
#############################
# ==============================================================================================================


resource "azurerm_storage_account" "storage1" {
  name                      = "myenv${element(var.regions,0)}st1"
  resource_group_name       = var.resource_group_name
  location                  = element(var.regions,0)
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
}

resource "azurerm_storage_container" "storage1containers" {
  for_each              =  var.containers
  name                  =  each.value
  storage_account_name  =  azurerm_storage_account.storage1.name
  container_access_type = "private"
}


resource "azurerm_storage_account" "storage2" {
  name                      = "myenv${element(var.regions,1)}st1"
  resource_group_name       = var.resource_group_name
  location                  = element(var.regions,1)
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
}

resource "azurerm_storage_container" "storage2containers" {
  for_each              =  var.containers
  name                  =  each.value
  storage_account_name  =  azurerm_storage_account.storage2.name
  container_access_type = "private"
}

#############################
#         SQL Server        #
#############################
# ==============================================================================================================
# Random password for SQL SERVER ADMIN account
resource "random_password" "azuresql_adm_pass" {
  length      = 14
  #special     = true
  min_lower   = 2
  min_upper   = 3
  min_numeric = 2
}

# Storage account for SQL Server auditing
resource "azurerm_storage_account" "sqlstorage1" {
  name                      = "myenv${element(var.regions,0)}sqladt"
  resource_group_name       = var.resource_group_name
  location                  = element(var.regions,0)
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = "true"
}

# EAST US
# ===============================================================
resource "azurerm_sql_server" "sql_server1" {
  name                         = element(var.sql_servers,0)
  resource_group_name          = var.resource_group_name
  location                     = element(var.regions,0)
  version                      = var.sql_version
  administrator_login          = var.sql_server_admin_user
  administrator_login_password = random_password.azuresql_adm_pass.result #var.sql_server_admin_passwd

  # Auditing for Azure SQL Database and Azure Synapse Analytics tracks database events
  # and writes them to an audit log in your Azure storage account, Log Analytics workspace, or Event Hubs.

  extended_auditing_policy {
      storage_endpoint                        = azurerm_storage_account.sqlstorage1.primary_blob_endpoint #"https://myenv${element(var.regions,0)}sqladt.blob.core.windows.net" #azurerm_storage_account.sqlstorage1.primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.sqlstorage1.primary_access_key
      storage_account_access_key_is_secondary = true
      retention_in_days                       = 6
    }

    tags = {
      environment = var.environment
    }
  }

resource "azurerm_sql_database" "db1" {
  name                = element(var.sql_databases,0)
  resource_group_name = var.resource_group_name
  location            = element(var.regions,0)
  server_name         = azurerm_sql_server.sql_server1.name

      extended_auditing_policy {
          storage_endpoint                        = azurerm_storage_account.sqlstorage1.primary_blob_endpoint #"https://myenv${element(var.regions,0)}sqladt.blob.core.windows.net" #azurerm_storage_account.sqlstorage1.primary_blob_endpoint
          storage_account_access_key              = azurerm_storage_account.sqlstorage1.primary_access_key
          storage_account_access_key_is_secondary = true
          retention_in_days                       = 6
        }

        tags = {
          environment = var.environment
        }
}

resource "azurerm_sql_database" "db2" {
  name                = element(var.sql_databases,1)
  resource_group_name = var.resource_group_name
  location            = element(var.regions,0)
  server_name         = azurerm_sql_server.sql_server1.name

      extended_auditing_policy {
          storage_endpoint                        = azurerm_storage_account.sqlstorage1.primary_blob_endpoint #"https://myenv${element(var.regions,0)}sqladt.blob.core.windows.net" #azurerm_storage_account.sqlstorage1.primary_blob_endpoint
          storage_account_access_key              = azurerm_storage_account.sqlstorage1.primary_access_key
          storage_account_access_key_is_secondary = true
          retention_in_days                       = 6
        }

        tags = {
          environment = var.environment
        }
}

resource "azurerm_sql_database" "db3" {
  name                = element(var.sql_databases,2)
  resource_group_name = var.resource_group_name
  location            = element(var.regions,0)
  server_name         = azurerm_sql_server.sql_server1.name

      extended_auditing_policy {
          storage_endpoint                        = azurerm_storage_account.sqlstorage1.primary_blob_endpoint #"https://myenv${element(var.regions,0)}sqladt.blob.core.windows.net" #azurerm_storage_account.sqlstorage1.primary_blob_endpoint
          storage_account_access_key              = azurerm_storage_account.sqlstorage1.primary_access_key
          storage_account_access_key_is_secondary = true
          retention_in_days                       = 6
        }

        tags = {
          environment = var.environment
        }
}

resource "azurerm_sql_firewall_rule" "sql_firewall1" {
    for_each            = var.sql_firewall_rule
    name                = each.value.firewall_rule_name
    resource_group_name = var.resource_group_name
    server_name         = azurerm_sql_server.sql_server1.name
    start_ip_address    = each.value.start_ip_address
    end_ip_address      = each.value.end_ip_address
  }
# WEST US
# ===============================================================
resource "azurerm_sql_server" "sql_server2" {
  name                         = element(var.sql_servers,1)
  resource_group_name          = var.resource_group_name
  location                     = element(var.regions,1)
  version                      = var.sql_version
  administrator_login          = var.sql_server_admin_user
  administrator_login_password = random_password.azuresql_adm_pass.result #var.sql_server_admin_passwd

  # Auditing for Azure SQL Database and Azure Synapse Analytics tracks database events
  # and writes them to an audit log in your Azure storage account, Log Analytics workspace, or Event Hubs.

  extended_auditing_policy {
      storage_endpoint                        = azurerm_storage_account.sqlstorage1.primary_blob_endpoint #"https://myenv${element(var.regions,0)}sqladt.blob.core.windows.net" #azurerm_storage_account.sqlstorage1.primary_blob_endpoint
      storage_account_access_key              = azurerm_storage_account.sqlstorage1.primary_access_key
      storage_account_access_key_is_secondary = true
      retention_in_days                       = 6
    }

    tags = {
      environment = var.environment
    }
  }

resource "azurerm_sql_firewall_rule" "sql_firewall2" {
    for_each            = var.sql_firewall_rule
    name                = each.value.firewall_rule_name
    resource_group_name = var.resource_group_name
    server_name         = azurerm_sql_server.sql_server2.name
    start_ip_address    = each.value.start_ip_address
    end_ip_address      = each.value.end_ip_address
  }

# FAILOVER
# ===============================================================
resource "azurerm_sql_failover_group" "sql_failover_group1" {
    name                = var.sql_failover_group
    resource_group_name = azurerm_sql_server.sql_server1.resource_group_name
    server_name         = azurerm_sql_server.sql_server1.name

    databases           = [azurerm_sql_database.db1.id,azurerm_sql_database.db2.id,azurerm_sql_database.db3.id]

    partner_servers {
      id = azurerm_sql_server.sql_server2.id
    }
  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}
