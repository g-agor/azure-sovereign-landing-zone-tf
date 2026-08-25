# Create a Resource Group for Shared Management Tools
resource "azurerm_resource_group" "management" {
  name     = "${var.root_id}-mgmt-rg"
  location = var.allowed_locations[0] # Defaults to uksouth
}

# Create Log Analytics Workspace for Centralized Monitoring
resource "azurerm_log_analytics_workspace" "central" {
  name                = "${var.root_id}-law"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}