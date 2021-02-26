output "linux_ssh_command" {
  value = "ssh ${module.linux-vm.linuxvm_username}@${module.linux-vm.linuxvm_ip}"
}

output "linuxvm_password" {
  description = "Linux VM Admin Passowrd"
  value       = module.linux-vm.linuxvm_password
}

output "windowsvm_pip" {
  description = "Windows VM Public IP"
  value       = module.windows-vm.windowsvm_ip
}

output "windowsvm_password" {
  description = "Windows VM Admin Passowrd"
  value       = module.windows-vm.windowsvm_password
}

output "windowsvm_user" {
  description = "Windows VM Admin User"
  value       = module.windows-vm.windowsvm_username
}
