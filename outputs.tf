output "root_management_group_id" {
  value       = azurerm_management_group.root.id
  description = "The ID of the Top-Level Root Management Group."
}

output "platform_management_group_id" {
  value       = azurerm_management_group.platform.id
  description = "The ID of the Platform Management Group."
}

output "landing_zones_management_group_id" {
  value       = azurerm_management_group.landing_zones.id
  description = "The ID of the Landing Zones Management Group."
}