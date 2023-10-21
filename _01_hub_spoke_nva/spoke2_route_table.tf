resource "azurerm_route_table" "route-table-to-nva-spoke2" {
  name                          = "route-table-to-nva-spoke2"
  location                      = azurerm_resource_group.rg-spoke2.location
  resource_group_name           = azurerm_resource_group.rg-spoke2.name
  disable_bgp_route_propagation = true
  tags                          = var.tags
}

resource "azurerm_route" "route-to-nva-spoke2" {
  name                   = "route-to-nva-spoke2"
  resource_group_name    = azurerm_resource_group.rg-spoke2.name
  route_table_name       = azurerm_route_table.route-table-to-nva-spoke2.name
  address_prefix         = azurerm_virtual_network.vnet-spoke1.address_space[0] # "10.1.0.0/16" # "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.vm-hub-nva.virtual_machine_private_ip
}

resource "azurerm_subnet_route_table_association" "association_route_table_subnet_spoke2" {
  subnet_id      = azurerm_subnet.subnet-spoke2-workload.id
  route_table_id = azurerm_route_table.route-table-to-nva-spoke2.id
}
