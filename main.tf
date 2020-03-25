provider "azurerm" {
  version = "1.44.0"
}

locals {
  virtual_machine_name = "${var.prefix}-vm"
}

resource "azurerm_virtual_machine" "compute" {
  name                = local.virtual_machine_name
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name

  network_interface_ids = [azurerm_network_interface.compute.id]
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
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }
}