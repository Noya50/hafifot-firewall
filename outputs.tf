output "name" {
  value       = azurerm_firewall.this.name
  description = "The name of the firewall."
}

output "id" {
  value       = azurerm_firewall.this.id
  description = "The id of the firewall."
}

output "location" {
  value       = azurerm_firewall.this.location
  description = "The location of the firewall."
}
output "resource_group_name" {
  value       = azurerm_firewall.this.resource_group_name
  description = "The name of the resource group of the firewall."
}
