variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_rg" {
  description = "name of the VM resource group"
  type = string
}

variable "vm_location" {
  description = "Location of the VM resource group"
  type = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_public_key_path" {
  description = "Path to the admin public SSH key"
  type        = string
}

variable "os_disk_caching" {
  description = "OS disk caching option"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "Publisher of the image"
  type        = string
}

variable "image_offer" {
  description = "Offer of the image"
  type        = string
}

variable "image_sku" {
  description = "SKU of the image"
  type        = string
}

variable "image_version" {
  description = "Version of the image"
  type        = string
}

variable "network_interface_id" {
  description = "ID of the network interface"
  type        = string
}

variable "use_custom_image" {
  type        = bool
  description = "Use custom image ID instead of marketplace image"
}

variable "custom_image_id" {
  type        = string
  default     = ""
  description = "Custom image ID (if use_custom_image is true)"
}

