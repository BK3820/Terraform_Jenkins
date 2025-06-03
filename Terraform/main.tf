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

terraform {
  cloud {
    organization = "JenkinsIac"

    workspaces {
      name = "Terraform_Jenkins"
    }
  }
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "Vnet" {

  source                               = "./modules/networking/Vnet"
  azurerm_virtual_network_name         = var.virtual_network_name
  azurerm_virtual_network_location     = azurerm_resource_group.rg.location
  azurerm_virtual_network_RG           = azurerm_resource_group.rg.name
  azurerm_virtual_network_addressSpace = var.vnet_address_space

}

module "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  source              = "./modules/networking/subnet"
  subnet_name         = each.value.name
  address_prefix      = each.value.address_prefix
  vnet_name           = module.Vnet.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
}


module "public_ips" {
  for_each = {
    for k, v in var.linuxvm : k => v if v.assign_public_ip # Key = "nginx", "jenkins"
  }

  source              = "./modules/networking/public_ip"
  name                = "${each.key}-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}



module "nics" {
  for_each = { for k, v in var.linuxvm : k => v }

  source            = "./modules/networking/NetworkInterfaceCard"
  NIC_name          = "${each.key}-NIC"
  NIC_location      = azurerm_resource_group.rg.location
  NIC_resourceGroup = azurerm_resource_group.rg.name
  ip_name           = each.key
  subnetiId         = module.subnets[each.value.nicname].subnet_id
  publicip_id       = each.value.assign_public_ip ? module.public_ips[each.key].id : null
}



module "virtualmachine" {
  for_each = { for s in var.linuxvm : s.name => s }

  source               = "./modules/compute/LinuxVM"
  vm_name              = "${each.value.name}-VM"
  vm_location          = azurerm_resource_group.rg.location
  vm_rg                = azurerm_resource_group.rg.name
  vm_size              = each.value.vm_size
  network_interface_id = module.nics[each.key].nic-id



  admin_username        = each.value.admin_username
  admin_public_key_path = each.value.admin_public_key_path

  use_custom_image = each.value.use_custom_image
  custom_image_id  = each.value.custom_image_id


  image_offer     = each.value.image_offer
  image_publisher = each.value.image_publisher
  image_sku       = each.value.image_sku
  image_version   = each.value.image_version
}


module "jenkins-nsg_with_rules" {
  source = "./modules/security/nsg"

  nsg_name     = "jenkins-nsg"
  nsg_location = azurerm_resource_group.rg.location
  nsg_rg       = azurerm_resource_group.rg.name

  nsg_rules = [
    {
      name                       = "allow-ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "deny-all-outbound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-jenkins-web"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-nginx-to-jenkins"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = module.nics["nginx"].private_ip_address
      destination_address_prefix = "*"
    }


  ]
}

module "nginx-nsg_with_rules" {
  source = "./modules/security/nsg"

  nsg_name     = "nginx-nsg"
  nsg_location = azurerm_resource_group.rg.location
  nsg_rg       = azurerm_resource_group.rg.name

  nsg_rules = [
    {
      name                       = "allow-ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-http"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-https"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-nginx-to-jenkins"
      priority                   = 130
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "*"
      destination_address_prefix = module.nics["jenkins"].private_ip_address
    }
  ]
}


resource "null_resource" "nginx-provisioner" {

  for_each = {
    for k, v in var.linuxvm : k => v if v.name == "nginx"
  }

  provisioner "file" {
    source      = "scripts/nginxinstall.sh"
    destination = "/tmp/nginxinstall.sh"
  }
  provisioner "file" {
    source      = "scripts/jenkins.conf.template"
    destination = "/tmp/jenkins.conf.template"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/nginxinstall.sh",
      format("/tmp/nginxinstall.sh %s", module.nics["jenkins"].private_ip_address)
    ]
  }


  connection {
    type        = "ssh"
    host        = module.virtualmachine[each.key].public_ip
    user        = "azureuser"
    private_key = file("./certs/vmkeyset")

  }

}


resource "azurerm_network_interface_security_group_association" "jenkins_nic_nsg_assoc" {
  network_interface_id      = module.nics["jenkins"].nic-id
  network_security_group_id = module.jenkins-nsg_with_rules.nsg_id
}

resource "azurerm_network_interface_security_group_association" "nginx_nic_nsg_assoc" {
  network_interface_id      = module.nics["nginx"].nic-id
  network_security_group_id = module.nginx-nsg_with_rules.nsg_id
}
