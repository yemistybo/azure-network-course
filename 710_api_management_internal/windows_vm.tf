resource "azurerm_network_interface" "nic-vm-windows" {
  name                = "nic-vm-windows"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-apim.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
}

resource "azurerm_windows_virtual_machine" "vm-windows" {
  name                  = "vm-windows-w11"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2als_v2"
  admin_username        = "azureuser"
  admin_password        = "@Aa123456789"
  network_interface_ids = [azurerm_network_interface.nic-vm-windows.id]

  # custom_data = filebase64("./install-tools-windows.ps1")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  # "imageReference": {
  #     "publisher": "microsoftwindowsdesktop",
  #     "offer": "windows-ent-cpc",
  #     "sku": "win11-23h2-pro-cpc-m365",
  #     "version": "latest"
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

# resource "azurerm_virtual_machine_extension" "cloudinit" {
#   name                 = "cloudinit"
#   virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"
#   settings             = <<SETTINGS
#     {
#         "commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/install.ps1; c:/azuredata/install.ps1\""
#     }
#     SETTINGS
# }