resource "azurerm_linux_virtual_machine" "example" {
  name                = var.vm_name
  resource_group_name = var.vm_rg
  location            = var.vm_location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    var.network_interface_id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}