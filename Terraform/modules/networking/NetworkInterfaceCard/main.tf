resource "azurerm_network_interface" "example" {
  name                = var.NIC_name
  location            = var.NIC_location
  resource_group_name = var.NIC_resourceGroup

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = var.subnetiId
    private_ip_address_allocation = "Dynamic"
  }
}