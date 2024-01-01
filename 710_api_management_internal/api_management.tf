resource "azurerm_api_management" "apim" {
  name                 = "apim-internal-${var.prefix}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  publisher_name       = "My Company"
  publisher_email      = "houssem.dellai@live.com"
  sku_name             = "Developer_1"
  virtual_network_type = "Internal" # None, External, Internal

  public_ip_address_id          = azurerm_public_ip.pip-apim.id
  public_network_access_enabled = true

  virtual_network_configuration {
    subnet_id = azurerm_subnet.subnet-apim.id
  }

  depends_on = [ azurerm_subnet_network_security_group_association.nsg-association ]
}

resource "azurerm_api_management_logger" "apim-logger" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_api_management.apim.resource_group_name
  resource_id         = azurerm_application_insights.app_insights.id

  application_insights {
    instrumentation_key = azurerm_application_insights.app_insights.instrumentation_key
  }
}
