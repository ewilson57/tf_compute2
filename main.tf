provider "azurerm" {
  version = "2.3.0"
  features {}
}

locals {
  virtual_machine_name = "${var.prefix}-vm"
}

data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

resource "azurerm_virtual_machine" "compute2" {
  name                = local.virtual_machine_name
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name

  network_interface_ids = [azurerm_network_interface.compute2.id]
  vm_size               = "Standard_D1_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.virtual_machine_name
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_key
    }
  }

  boot_diagnostics {
    enabled     = false
    storage_uri = ""
  }
}
