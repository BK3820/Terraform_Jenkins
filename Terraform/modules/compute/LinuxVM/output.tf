output "public_ip" {
  value = azurerm_linux_virtual_machine.module-linuxvm.public_ip_address
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.module-linuxvm.private_ip_address
}

output "vmname" {
  value = azurerm_linux_virtual_machine.module-linuxvm.name
}