output "windowsvm_ip" {
  description = "VM IP"
  value       = azurerm_windows_virtual_machine.windowsvm.public_ip_address
}

output "windowsvm_username" {
  description = "VM username"
  value       = var.vm_user
}

output "windowsvm_password" {
  description = "VM admin password"
  value       = random_password.adminpassword.result
}
