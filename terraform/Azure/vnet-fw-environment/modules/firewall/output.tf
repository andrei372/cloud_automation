output "firewall_private_ip" {
  value = azurerm_firewall.fw.ip_configuration.0.private_ip_address
}

output "firewall_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
