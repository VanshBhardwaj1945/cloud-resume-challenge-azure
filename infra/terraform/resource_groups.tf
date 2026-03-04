# Resource Groups

resource "azurerm_resource_group" "crc-frontend-rg" {
  name     = "crc-frontend-rg"
  location = "Central US"
}

resource "azurerm_resource_group" "crc-backend-rg" {
  name     = "crc-backend-rg"
  location = "Central US"
}
