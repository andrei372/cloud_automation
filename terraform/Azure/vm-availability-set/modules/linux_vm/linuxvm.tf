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

  # allow ssh in
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                ="${var.server_name}-nic"
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

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                            = var.server_name
  location                        = element(var.regions,0)
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = var.server_name
  admin_username                  = var.vm_user

  # OPTION 1 - FOR PASSWORD ACCESS
  admin_password                  = random_password.adminpassword.result
  disable_password_authentication = false


  # OPTION 2 - FOR SSH KEY PAIR access
  /*
  admin_ssh_key {
    username   = var.vm_user
    public_key = file("~/.ssh/id_rsa.pub")
  }
  disable_password_authentication = true
  */

  availability_set_id = var.availability_set_id
  
  os_disk {
    name                 = "linuxVMOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # NOT RECOMMENDED but usable with Terraform to provision OS
  provisioner "remote-exec" {
    connection {
      host     = self.public_ip_address
      type     = "ssh"
      user     = var.vm_user
      password = random_password.adminpassword.result
    }

    # commands sent to the VM to deploy tools
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y tree",
      "sudo apt-get install -y htop",
      "sudo apt-get install -y nmap"
    ]
  }
}
