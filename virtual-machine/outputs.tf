output "vm_public_ip" {
  value       = azurerm_public_ip.miprimeravmpublicip.ip_address
  description = "IP pública de la máquina virtual"
}