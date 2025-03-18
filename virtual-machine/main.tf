# Definición del provider que ocuparemos
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "miprimeravmrg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "miprimeravmvnet" {
  name                = var.virtual_network_name
  address_space       = [var.virtual_network_address_space]
  location            = azurerm_resource_group.miprimeravmrg.location
  resource_group_name = azurerm_resource_group.miprimeravmrg.name
}

resource "azurerm_subnet" "miprimeravmsubnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.miprimeravmrg.name
  virtual_network_name = azurerm_virtual_network.miprimeravmvnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_public_ip" "miprimeravmpublicip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.miprimeravmrg.location
  resource_group_name = azurerm_resource_group.miprimeravmrg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "miprimeravmnic" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.miprimeravmrg.location
  resource_group_name = azurerm_resource_group.miprimeravmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.miprimeravmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.miprimeravmpublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "miprimeravm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.miprimeravmrg.name
  location            = azurerm_resource_group.miprimeravmrg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.miprimeravmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  disable_password_authentication = false
  provision_vm_agent              = true
}

resource "azurerm_network_security_group" "miprimeravmnsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.miprimeravmrg.location
  resource_group_name = azurerm_resource_group.miprimeravmrg.name

  security_rule {
    name                       = "ssh_rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "miprimeravmnicnsg" {
  network_interface_id      = azurerm_network_interface.miprimeravmnic.id
  network_security_group_id = azurerm_network_security_group.miprimeravmnsg.id
}
