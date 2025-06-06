resource "azurerm_linux_virtual_machine" "module-linuxvm" {
  name                  = var.vm_name
  resource_group_name   = var.vm_rg
  location              = var.vm_location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [var.network_interface_id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_public_key_path)
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  # Conditional image usage
  source_image_id = var.use_custom_image ? var.custom_image_id : null

  dynamic "source_image_reference" {
    for_each = var.use_custom_image ? [] : [1]
    content {
      publisher = var.image_publisher
      offer     = var.image_offer
      sku       = var.image_sku
      version   = var.image_version
    }
  }
}
