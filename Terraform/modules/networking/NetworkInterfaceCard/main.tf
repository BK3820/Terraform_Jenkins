resource "azurerm_network_interface" "module-nic" {
  name                = var.NIC_name
  location            = var.NIC_location
  resource_group_name = var.NIC_resourceGroup

  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = var.subnetiId
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.publicip_id != "" ? var.publicip_id : null
  }
}