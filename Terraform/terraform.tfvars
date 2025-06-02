resource_group_name     = "rg-dev"
resource_group_location = "Canada Central"

virtual_network_name = "vnet-dev"

subnets = [
  {
    name           = "subnet-nginx"
    address_prefix = "10.0.1.0/24"
  },
  {
    name           = "subnet-jenkins"
    address_prefix = "10.0.2.0/24"
  }
]



linuxvm = {
  nginx = {
    name                  = "nginx"
    vm_size               = "Standard_B1s"
    nicname               = "subnet-nginx"
    admin_username        = "azureuser"
    admin_public_key_path = "./certs/vmkeyset.pub"
    image_offer           = "0001-com-ubuntu-server-jammy"
    image_publisher       = "Canonical"
    image_sku             = "22_04-lts"
    image_version         = "latest"
    assign_public_ip      = true

    use_custom_image = false
    custom_image_id  = ""
  }

  jenkins = {
    name                  = "jenkins"
    vm_size               = "Standard_B2s"
    nicname               = "subnet-jenkins"
    admin_username        = "azureuser"
    admin_public_key_path = "./certs/vmkeyset.pub"
    image_offer           = ""
    image_publisher       = ""
    image_sku             = ""
    image_version         = ""
    assign_public_ip      = true

    use_custom_image = true
    custom_image_id  = "/subscriptions/96dd7bbb-5319-4ad7-93a1-ff1de8e90a9b/resourceGroups/vmImage/providers/Microsoft.Compute/images/jenkins-image"
  }
}
