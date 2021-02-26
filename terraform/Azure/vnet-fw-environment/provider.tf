# Configure the Azure provider
# ============================================================================================================
# Configure the Microsoft Azure Provider.
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.43.0"
  skip_provider_registration = true

  # The "feature" block is required for AzureRM provider 2.x.
  features {}
}

terraform {
  backend "azurerm" {
    #https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage

    resource_group_name      = "myenv-settings-rg"
    storage_account_name     = "tfconfigstates"
    container_name           = "tfstate"
    key                      = "vnet-fw-env.tfstate"
  }
}
