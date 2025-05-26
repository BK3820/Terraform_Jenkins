variable "azurerm_virtual_network_RG" {

    description = "Resource group of Vnet"
  
}

variable "azurerm_virtual_network_name" {

    description = "Name of the Vnet"
  
}

variable "azurerm_virtual_network_location" {

    description = "Location of the vnet"

}

variable "azurerm_virtual_network_addressSpace" {
  type = list(string)
  description = "Address Space of the Vnet"
}
