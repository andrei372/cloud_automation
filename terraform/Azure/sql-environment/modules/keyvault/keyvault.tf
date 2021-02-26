data "azurerm_client_config" "current" {}

#############################
#         Key Vault         #
#############################
# ==============================================================================================================
resource "azurerm_key_vault" "kv" {
  name                = var.keyvaultname
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name

  sku_name = "standard"

  tenant_id = data.azurerm_client_config.current.tenant_id

  enabled_for_disk_encryption     = true
  #soft_delete_enabled            = true         # Azure has removed support for disabling Soft Delete as of 2020-12-15, as such this field is no longer configurable
  purge_protection_enabled        = false         # When purge protection is on, a vault or an object in the deleted state cannot be purged until the retention period has passed
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
}

resource "azurerm_key_vault_access_policy" "kvpolicy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get",
    "create",
    "import",
    "encrypt",
    "list",
    "backup",
    "update",
    "verify"
  ]

  secret_permissions = [
    "get",
    "list",
    "backup",
    "set",
    "delete",
    "recover"
  ]

  storage_permissions = [
    "get",
    "list",
    "backup",
    "listsas",
    "restore",
    "update",
    "set"
  ]
}

# KEYS
# ===============================================================
/*
# Key vault secrets
resource "azurerm_key_vault_secret" "azsecret" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.kv.id
}
*/
