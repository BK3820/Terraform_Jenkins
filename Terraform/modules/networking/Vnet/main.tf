

resource "azurerm_virtual_network" "Vnet" {
  name                = var.azurerm_virtual_network_name
  resource_group_name = var.azurerm_virtual_network_RG
  location            = var.azurerm_virtual_network_location
  address_space       = var.azurerm_virtual_network_addressSpace
}