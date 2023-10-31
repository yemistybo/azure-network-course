resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# resource "azurerm_user_assigned_identity" "identity_vm" {
#   name                = "identity-vm"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   tags                = var.tags
# }

# resource "azurerm_role_assignment" "role_contributor" {
#   scope                            = var.subscription_id
#   role_definition_name             = "Contributor"
#   principal_id                     = azurerm_user_assigned_identity.identity_vm.principal_id
#   skip_service_principal_aad_check = true
# }

resource "azurerm_public_ip" "pip_vm" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic_vm" {
  name                 = "nic-vm"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = var.enable_ip_forwarding
  tags                 = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip_vm.0.id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.nic_vm.id]
  tags                            = var.tags

  custom_data = var.install_webapp ? filebase64("../scripts/install-webapp.sh") : null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy" # "0001-com-ubuntu-minimal-mantic" # "UbuntuServer" # "0001-com-ubuntu-server-jammy" # "0001-com-ubuntu-minimal-jammy"
    sku       = "22_04-lts-gen2" # "minimal-23_10-gen2" # "18.04-LTS"    # "22.04-LTS-gen2" # "22_04-lts-gen2" # "minimal-22_04-lts-gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  # identity {
  #   type         = "UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.identity_vm.id]
  # }

  # az vm image list --publisher Canonical --offer 0001-com-ubuntu-pro-jammy -s pro-22_04-lts-gen2 --all
  # az vm image terms accept --urn "Canonical:0001-com-ubuntu-pro-jammy:pro-22_04-lts-gen2:22.04.202209211"
  # plan {
  #   name = "22_04-lts-gen2" # "minimal-22_04-lts-gen2"
  #   product = "0001-com-ubuntu-server-jammy" # "0001-com-ubuntu-minimal-jammy"
  #   publisher = "Canonical"
  # }
}

resource "azurerm_virtual_machine_extension" "install-webapp" {
  count                = var.install_webapp ? 0 : 0
  name                 = "install-webapp"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  tags                 = var.tags
  settings             = <<SETTINGS
    {
      "fileUris": ["https://raw.githubusercontent.com/HoussemDellai/azure-network-hub-spoke/main/scripts/install-webapp.sh"],
      "commandToExecute": "bash install-webapp.sh"
    }
SETTINGS
  #   settings             = <<SETTINGS
  #     {
  #       "fileUris": ["https://raw.githubusercontent.com/HoussemDellai/azure-network-hub-spoke/main/scripts/install-webapp.sh"],
  #       "commandToExecute": "./install-webapp.sh"
  #     }
  # SETTINGS
}
