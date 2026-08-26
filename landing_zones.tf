# Create Resource Group for Application / Workload Landing Zone
resource "azurerm_resource_group" "workload" {
  name     = "${var.root_id}-workload-rg"
  location = var.allowed_locations[0] # uksouth
}

# Create Workload Landing Zone Virtual Network
resource "azurerm_virtual_network" "workload" {
  name                = "${var.root_id}-workload-vnet"
  location            = azurerm_resource_group.workload.location
  resource_group_name = azurerm_resource_group.workload.name
  address_space       = ["10.1.0.0/16"]
}

# Create Subnet for Application Services inside the Workload VNet
resource "azurerm_subnet" "app" {
  name                 = "AppServicesSubnet"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.workload.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Bi-directional Peering: Central Hub VNet -> Workload VNet
resource "azurerm_virtual_network_peering" "hub_to_workload" {
  name                      = "peer-hub-to-workload"
  resource_group_name       = azurerm_resource_group.network.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.workload.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Bi-directional Peering: Workload VNet -> Central Hub VNet
resource "azurerm_virtual_network_peering" "workload_to_hub" {
  name                      = "peer-workload-to-hub"
  resource_group_name       = azurerm_resource_group.workload.name
  virtual_network_name      = azurerm_virtual_network.workload.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}