# Fetch the Root Management Group
data "azurerm_management_group" "root" {
  name = "${var.root_id}-root"
}

# Fetch Built-in "Allowed locations" Policy Definition
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

# Policy Assignment: Restrict Allowed Locations to UK Regions
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-uk"
  management_group_id  = data.azurerm_management_group.root.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  description          = "Enforces sovereign data residency by restricting resource deployments strictly to UK regions."
  display_name         = "Allowed Locations (UK Sovereign Only)"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}