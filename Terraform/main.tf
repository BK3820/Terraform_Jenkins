terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg" {
  name     = "sampleRG"
  location = "canadacentral"
}

module "Vnet" {

    source = "./modules/networking/Vnet"
    azurerm_virtual_network_name = "sampleVnet"
    azurerm_virtual_network_location = azurerm_resource_group.rg.location
    azurerm_virtual_network_RG = azurerm_resource_group.rg.name
    azurerm_virtual_network_addressSpace = [ "10.0.0.0/16" ]
  
}


