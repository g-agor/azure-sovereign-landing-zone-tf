# Fetch current caller identity (user/service principal running Terraform)
data "azurerm_client_config" "current" {}

# Fetch Management Groups created in Step 2
data "azurerm_management_group" "connectivity" {
  name = "${var.root_id}-connectivity"
}

data "azurerm_management_group" "management" {
  name = "${var.root_id}-management"
}

# 1. Reader Role at Top-Level Root (Inherited across all child management groups for auditing)
resource "azurerm_role_assignment" "root_reader" {
  scope                = data.azurerm_management_group.root.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

# 2. Network Contributor Role at Connectivity scope (Manage VNets, ExpressRoute, Firewalls)
resource "azurerm_role_assignment" "network_admin" {
  scope                = data.azurerm_management_group.connectivity.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# 3. Security Admin Role at Management scope (Manage Log Analytics & Sentinel)
resource "azurerm_role_assignment" "security_admin" {
  scope                = data.azurerm_management_group.management.id
  role_definition_name = "Security Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}