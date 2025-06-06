packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "2.0.2"
    }
  }
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}


source "azure-arm" "sig_image" {

  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id


  location                          = "canadacentral"
  os_type                           = "Linux"
  vm_size                           = "Standard_B1ms"
  image_publisher                   = "canonical"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_sku                         = "22_04-lts"
  image_version                     = "latest"
  managed_image_name                = "jenkins-image"
  managed_image_resource_group_name = "vmImage"

}

build {
  sources = ["source.azure-arm.sig_image"]

  provisioner "file" {
    source      = "jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }

  provisioner "file" {
  source      = "plugin.txt"
  destination = "/tmp/plugins.txt"
}

  provisioner "file" {
  source      = "jenkins.yaml"
  destination = "/tmp/jenkins.yaml"
}

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/jenkins.sh",
      "bash /tmp/jenkins.sh"
    ]

  }
}
