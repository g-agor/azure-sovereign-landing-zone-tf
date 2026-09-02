# Output Management Group IDs
output "root_management_group_id" {
  description = "The ID of the Root Management Group"
  value       = azurerm_management_group.root.id
}

output "connectivity_management_group_id" {
  description = "The ID of the Connectivity Management Group"
  value       = azurerm_management_group.connectivity.id
}

output "management_management_group_id" {
  description = "The ID of the Management Management Group"
  value       = azurerm_management_group.management.id
}

# Output Active Caller Identity Details
output "deployed_by_object_id" {
  description = "The Object ID of the execution account assigned RBAC roles"
  value       = data.azurerm_client_config.current.object_id
}
