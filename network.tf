

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
# Creación del recurso de red

resource "azurerm_virtual_network" "VMnetworkIPY" {
  name                = "Virtual-network-IPY"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  tags = {
	enviroment = "casopractico2"
	}
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
# Creación de la subred

resource "azurerm_subnet" "SubnetworkIPY" {
  name                 = "SubnetworkIPYcp2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VMnetworkIPY.name
  address_prefixes     = ["172.16.0.0/24"]
  
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
# Creación del interface virtual - NIC - ip privada

resource "azurerm_network_interface" "VMnicIPY" {
  name                = "IPY-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          	= "ipprivvm"
    subnet_id                     	= azurerm_subnet.SubnetworkIPY.id
    private_ip_address_allocation 	= "Static"
	private_ip_address				= "172.16.0.79"
	public_ip_address_id			= azurerm_public_ip.PublicipIPY.id
	}

  tags = {
	enviroment = "casopractico2"
	}
}

#Creación del interface virtual - ip pública
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "PublicipIPY" {
  name                = "PublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  sku				  = "Basic"

  tags = {
    environment = "casopractico2"
  }
}



data "azurerm_public_ip" "PublicipIPY" {
  name                = azurerm_public_ip.PublicipIPY.name
  resource_group_name = azurerm_linux_virtual_machine.VMIPYDevops.resource_group_name
}

output "public_ip_address" {
  value = data.azurerm_public_ip.PublicipIPY.ip_address
}
