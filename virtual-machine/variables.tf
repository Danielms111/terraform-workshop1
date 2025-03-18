variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
  default = ""
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "miprimeravmrg"
}

variable "location" {
  description = "Región de Azure donde se desplegarán los recursos"
  type        = string
  default     = "West Europe"
}

variable "virtual_network_name" {
  description = "Nombre de la red virtual"
  type        = string
  default     = "miprimeravmvnet"
}

variable "virtual_network_address_space" {
  description = "Espacio de direcciones de la red virtual"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_name" {
  description = "Nombre de la subred"
  type        = string
  default     = "miprimeravmsubnet"
}

variable "subnet_address_prefix" {
  description = "Prefijo de direcciones de la subred"
  type        = string
  default     = "10.0.2.0/24"
}

variable "network_interface_name" {
  description = "Nombre de la interfaz de red"
  type        = string
  default     = "miprimeravmnic"
}

variable "public_ip_name" {
  description = "Nombre de la IP pública"
  type        = string
  default     = "miprimeravmpublicip"
}

variable "nsg_name" {
  description = "Nombre del grupo de seguridad de red"
  type        = string
  default     = "miprimeravmnsg"
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
  default     = "miprimeravm"
}

variable "vm_size" {
  description = "Tamaño de la máquina virtual"
  type        = string
  default     = "Standard_F2"
}

variable "admin_username" {
  description = "Nombre de usuario administrador"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  description = "Contraseña del usuario administrador"
  type        = string
  default     = "Password*#123"
}

variable "os_disk_storage_type" {
  description = "Tipo de almacenamiento del disco OS"
  type        = string
  default     = "Standard_LRS"
}

variable "image_publisher" {
  description = "Proveedor de la imagen del sistema operativo"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Oferta de la imagen del sistema operativo"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "SKU de la imagen del sistema operativo"
  type        = string
  default     = "22_04-lts"
}

variable "image_version" {
  description = "Versión de la imagen del sistema operativo"
  type        = string
  default     = "latest"
}
