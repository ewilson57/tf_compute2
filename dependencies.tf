resource "azurerm_resource_group" "compute2" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "compute2" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name
}

resource "azurerm_network_security_group" "compute2" {
  name                = "linux_base"
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name

  security_rule {
    name              = "ssh_http"
    priority          = 100
    direction         = "Inbound"
    access            = "Allow"
    protocol          = "Tcp"
    source_port_range = "*"
    destination_port_ranges = [
      "22",
      "80"
    ]
    source_address_prefix      = var.router_wan_ip
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Test"
  }
}

resource "azurerm_subnet" "compute2" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.compute2.name
  virtual_network_name = azurerm_virtual_network.compute2.name
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_subnet_network_security_group_association" "compute2" {
  subnet_id                 = azurerm_subnet.compute2.id
  network_security_group_id = azurerm_network_security_group.compute2.id
}

resource "azurerm_public_ip" "compute2" {
  name                = "${var.prefix}-publicip"
  resource_group_name = azurerm_resource_group.compute2.name
  location            = azurerm_resource_group.compute2.location
  allocation_method   = "Dyanmic"
}

resource "azurerm_network_interface" "compute2" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.compute2.location
  resource_group_name = azurerm_resource_group.compute2.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.compute2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.compute2.id
  }
}
