variable "nsg_name" {
  description = "Name of the NSG"
  type        = string
}

variable "nsg_location" {
  description = "Location for the NSG"
  type        = string
}

variable "nsg_rg" {
  description = "Resource Group Name"
  type        = string
}

variable "tags" {
  description = "Tags for the NSG"
  type        = map(string)
  default     = {}
}

variable "nsg_rules" {
  description = "List of NSG rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
