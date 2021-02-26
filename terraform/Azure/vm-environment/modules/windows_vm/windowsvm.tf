resource "azurerm_public_ip" "pip" {
  name                = "${var.server_name}-pip"
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "vm_sg" {
  name                = "${var.server_name}-sg"
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name

  # allow RDP in
  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.server_name}-nic"
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.server_name}vmNicConf"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id
}

//Create random password for our admin username
resource "random_password" "adminpassword" {
  keepers = {
    resource_group = var.resource_group_name
  }

  length      = 10
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                            = var.server_name
  location                        = element(var.regions,0)
  resource_group_name             = var.resource_group_name
  size                            = "Standard_DS1_v2"
  computer_name                   = var.server_name
  admin_username                  = var.vm_user
  admin_password                  = random_password.adminpassword.result

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    name                 = "windowsVMOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer     = "WindowsServer"
     sku       = "2016-Datacenter"
     version   = "latest"
   }
}
