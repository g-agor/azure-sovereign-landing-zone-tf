# Fetch the Root Management Group
data "azurerm_management_group" "root" {
  name = "${var.root_id}-root"
}

# Fetch Built-in "Allowed locations" Policy Definition
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

# 1. Existing Policy Assignment: Restrict Allowed Locations to UK Regions
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

# 2. Custom Policy Definition: Require Environment Tag
resource "azurerm_policy_definition" "require_tag_environment" {
  name                = "sovereign-require-env-tag"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require Environment Tag"
  description         = "Denies creation of resources that lack the mandatory Environment tag."
  management_group_id = data.azurerm_management_group.root.id

  metadata = jsonencode({
    category = "Cost & Governance"
  })

  policy_rule = jsonencode({
    if = {
      field  = "tags['Environment']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })
}

# 3. Policy Assignment: Enforce Mandatory Tag at Sovereign Root
resource "azurerm_management_group_policy_assignment" "require_env_tag" {
  name                 = "env-tag-assignment"
  management_group_id  = data.azurerm_management_group.root.id
  policy_definition_id = azurerm_policy_definition.require_tag_environment.id
  display_name         = "Enforce Mandatory Environment Tag"
}