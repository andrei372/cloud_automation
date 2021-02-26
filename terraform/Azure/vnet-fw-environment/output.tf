output "firewall_private_ip" {
  value = module.firewall.firewall_private_ip
}

output "firewall_public_ip" {
  value = module.firewall.firewall_public_ip
}
/*
output "firewall_subnet_space" {
  value = module.hub_network.???
}

output "firewall_subnet_space_address_prefix" {
  value = module.hub_network.???
}
*/
