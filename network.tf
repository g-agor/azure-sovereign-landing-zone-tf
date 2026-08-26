# Create Resource Group for Hub Networking
resource "azurerm_resource_group" "network" {
  name     = "${var.root_id}-network-rg"
  location = var.allowed_locations[0] # uksouth
}

# Create Core Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = "${var.root_id}-hub-vnet"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
}

# Create Management/Shared Services Subnet
resource "azurerm_subnet" "management" {
  name                 = "ManagementSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Azure Firewall Dedicated Subnet (Requires explicit name)
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create Gateway Dedicated Subnet (Requires explicit name)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create Network Security Group for Management Subnet
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "${var.root_id}-hub-nsg"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
}

# Associate NSG to Management Subnet
resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_assoc" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
}

resource "azurerm_resource_group" "network" {
  name     = "${var.root_id}-network-rg"
  location = var.allowed_locations[0]
  tags     = var.default_tags
}