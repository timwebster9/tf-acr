resource "azurerm_resource_group" "acr_rg" {
  name     = "acr-rg"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "897safsacr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Basic"
  admin_enabled       = false
}
