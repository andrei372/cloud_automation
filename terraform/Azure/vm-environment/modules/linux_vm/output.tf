output "linuxvm_ip" {
  description = "VM IP"
  value       = azurerm_linux_virtual_machine.linuxvm.public_ip_address
}

output "linuxvm_username" {
  description = "VM username"
  value       = var.vm_user
}

output "linuxvm_password" {
  description = "VM admin password"
  value       = random_password.adminpassword.result
}
