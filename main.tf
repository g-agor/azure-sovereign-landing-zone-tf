# Top-Level Root Management Group
resource "azurerm_management_group" "root" {
  display_name = var.root_name
  name         = "${var.root_id}-root"
}

# Tier 1: Platform Parent Group
resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  name                       = "${var.root_id}-platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Tier 2: Platform Sub-Groups (Connectivity, Identity, Management)
resource "azurerm_management_group" "connectivity" {
  display_name               = "Connectivity"
  name                       = "${var.root_id}-connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  display_name               = "Identity"
  name                       = "${var.root_id}-identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  display_name               = "Management"
  name                       = "${var.root_id}-management"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Tier 1: Landing Zones Parent Group
resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing Zones"
  name                       = "${var.root_id}-landing-zones"
  parent_management_group_id = azurerm_management_group.root.id
}

# Tier 2: Landing Zone Sub-Group (Production Workloads)
resource "azurerm_management_group" "production" {
  display_name               = "Production Workloads"
  name                       = "${var.root_id}-production"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Tier 1: Decommissioned / Sandbox Parent Group
resource "azurerm_management_group" "decommissioned" {
  display_name               = "Decommissioned"
  name                       = "${var.root_id}-decommissioned"
  parent_management_group_id = azurerm_management_group.root.id
}