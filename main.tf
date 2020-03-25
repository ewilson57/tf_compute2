provider "azurerm" {
  version = "1.44.0"
}

locals {
  virtual_machine_name = "${var.prefix}-vm"
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
}

resource "azurerm_dev_test_lab" "compute2" {
  name                = "shutdown-computevm-${local.virtual_machine_name}"
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name
}

resource "azurerm_dev_test_schedule" "compute2" {
  name                = "${local.virtual_machine_name}-AutoStop"
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name
  lab_name            = azurerm_dev_test_lab.compute2.name

  daily_recurrence {
    time      = "2300"
  }

  time_zone_id = "Eastern Standard Time"
  task_type    = "LabVmsShutdownTask"

  notification_settings {
  }
}