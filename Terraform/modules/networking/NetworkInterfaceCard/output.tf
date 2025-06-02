output "nic-id" {
  value = azurerm_network_interface.module-nic.id
}

output "private_ip_address" {
  value = azurerm_network_interface.module-nic.private_ip_address
}
