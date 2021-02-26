resource "azurerm_virtual_network_peering" "peering-one-way" {
  name                      = var.peering_name_1_to_2
  resource_group_name       = var.vnet_1_rg
  virtual_network_name      = var.vnet_1_name
  remote_virtual_network_id = var.vnet_2_id
}

resource "azurerm_virtual_network_peering" "peering-back-way" {
  name                      = var.peering_name_2_to_1
  resource_group_name       = var.vnet_2_rg
  virtual_network_name      = var.vnet_2_name
  remote_virtual_network_id = var.vnet_1_id
}
