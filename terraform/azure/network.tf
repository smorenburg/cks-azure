# Create the virtual network.
resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.10.0.0/16"]
}

# Create the subnet.
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Create the network security group.
resource "azurerm_network_security_group" "default" {
  name                = "nsg-default-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
}

# Create the route table.
resource "azurerm_route_table" "default" {
  name                = "rt-default-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
}

# Associate the network security group with the subnet.
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

# Associate the route table with the subnet.
resource "azurerm_subnet_route_table_association" "default" {
  subnet_id      = azurerm_subnet.default.id
  route_table_id = azurerm_route_table.default.id
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSshInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = ["${local.public_ip}/32"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.default.name
}

resource "azurerm_network_security_rule" "node_ports" {
  name                        = "AllowNodePortsInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "30000-40000"
  source_address_prefixes     = ["${local.public_ip}/32"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.default.name
}
