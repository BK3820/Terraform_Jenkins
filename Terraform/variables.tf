variable "resource_group_name" {

  type        = string
  description = "Name of the resource group"

}

variable "resource_group_location" {
  type        = string
  description = "location of resoruce group"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the Vnet"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  type = list(object({
    name           = string
    address_prefix = string
  }))
}

variable "linuxvm" {
  type = map(object({
    name                  = string
    vm_size               = string
    nicname               = string
    admin_username        = string
    admin_public_key_path = string
    assign_public_ip      = bool

    # ADD these:
    use_custom_image = bool
    custom_image_id  = string

    image_offer     = string
    image_publisher = string
    image_sku       = string
    image_version   = string
  }))
}

