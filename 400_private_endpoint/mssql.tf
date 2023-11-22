resource "azurerm_mssql_server" "mssql-server" {
  name                          = "sqlserver-400"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = "azureuser"
  administrator_login_password  = "@Aa123456789"
  public_network_access_enabled = false

  netw
}

resource "azurerm_mssql_database" "database" {
  name           = "products-db"
  server_id      = azurerm_mssql_server.mssql-server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  read_scale     = false
  sku_name       = "Basic" # GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100
  zone_redundant = false
}
