terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-alz-prod"
    storage_account_name = "tfstatest123450"
    container_name       = "tfstate"
    key                  = "landingzone.tfstate"
  }
}