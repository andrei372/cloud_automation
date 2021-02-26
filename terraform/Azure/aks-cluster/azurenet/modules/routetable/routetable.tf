resource "azurerm_route_table" "rt" {
  name                = var.rt_name
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name

  route {
    name                   = var.r_name
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.rt.id
}
