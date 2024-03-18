
# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


#resource "aws_key_pair" "generated_key" {
#  key_name   = var.key_name
#  public_key = tls_private_key.rsa-4096-example.public_key_openssh
#}


#Creación de VM IPIDevops en Azure

resource "azurerm_linux_virtual_machine" "VMIPYDevops" {
  name                = "IPYDevops-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = "VMunirIPY"
  network_interface_ids = [ azurerm_network_interface.VMnicIPY.id ]
  disable_password_authentication = true


 admin_ssh_key {
    username = "VMunirIPY"
    public_key = tls_private_key.rsa-4096-example.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  	
  source_image_reference {
	publisher	= "Canonical"
    offer    	= "0001-com-ubuntu-server-jammy"
    sku      	= "22_04-lts-gen2"
    version   	= "latest"
  }



  tags = {
    environment = "casopractico2"
  }
}

output "ssh_private_key" {
  value 	= tls_private_key.rsa-4096-example.private_key_pem
  sensitive = true
}
