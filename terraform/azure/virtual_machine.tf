# Create the network interface and public IP address for the control plane.
resource "azurerm_network_interface" "control_001" {
  name                = "nic-vm-control-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.control_001.id
  }
}

resource "azurerm_public_ip" "control_001" {
  name                = "pip-vm-control-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Dynamic"
  domain_name_label   = "vm-control-${local.suffix}-001"
}

# Create the control plane.
resource "azurerm_linux_virtual_machine" "control_001" {
  name                = "vm-control-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  computer_name       = "control-001"
  size                = "Standard_D2s_v5"
  admin_username      = "adminuser"
  secure_boot_enabled = true

  network_interface_ids = [
    azurerm_network_interface.control_001.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    name                   = "osdisk-vm-control-${local.suffix}-001"
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.default.id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Create the network interface and public IP address for the node.
resource "azurerm_network_interface" "node_001" {
  name                = "nic-vm-node-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node_001.id
  }
}

resource "azurerm_public_ip" "node_001" {
  name                = "pip-vm-node-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Dynamic"
  domain_name_label   = "vm-node-${local.suffix}-001"
}

# Create the node.
resource "azurerm_linux_virtual_machine" "node_001" {
  name                = "vm-node-${local.suffix}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  computer_name       = "node-001"
  size                = "Standard_D2s_v5"
  admin_username      = "adminuser"
  secure_boot_enabled = true

  network_interface_ids = [
    azurerm_network_interface.node_001.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    name                   = "osdisk-vm-node-${local.suffix}-001"
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.default.id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}
