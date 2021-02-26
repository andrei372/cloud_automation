resource "azurerm_public_ip" "pip" {
  name                = "vm-pip"
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "vm_sg" {
  name                = "vm-sg"
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
  name                = "vm-nic"
  location            = element(var.regions,0)
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "vmNicConfiguration"
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

  length      = 18
  min_lower   = 2
  min_upper   = 4
  min_numeric = 3
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                            = "jumpboxvm"
  location                        = element(var.regions,0)
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "jumpboxvm"
  admin_username                  = var.vm_user

  # FOR PASSWORD ACCESS
  # admin_password                  = random_password.adminpassword.result
  # disable_password_authentication = true

  # FOR SSH KEY PAIR access
  admin_ssh_key {
    username   = var.vm_user
    public_key = file("~/.ssh/id_rsa.pub")
  }
  disable_password_authentication = true

  os_disk {
    name                 = "jumpboxOsDisk"
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
      # FOR SSH KEY PAIR access
      private_key = file("~/.ssh/id_rsa")

      # FOR PASSWORD access
      password = random_password.adminpassword.result
    }

    # commands sent to the VM to deploy tools
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y tree && sudo apt-get install -y htop && sudo apt-get install -y nmap && sudo apt-get install -y apt-transport-https gnupg2",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubectl",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "hublink" {
  name                  = "hubnetdnsconfig"
  resource_group_name   = var.dns_zone_resource_group_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.vnet_id
}
