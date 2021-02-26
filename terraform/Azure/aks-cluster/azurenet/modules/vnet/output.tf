output vnet_id {
  description = "Generated VNET ID"
  value       = azurerm_virtual_network.vnet.id
}

output vnet_name {
  description = "Generated VNET Name"
  value       = azurerm_virtual_network.vnet.name
}

output subnet_ids {
  description = "Generated subnet IDs map"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}
