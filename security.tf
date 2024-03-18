
resource "azurerm_network_security_group" "SecuritygroupIPY" {
  name                = "acceptsshipy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80", "8080"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "casopractico2"
  }
}


#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "networksecurityassociation" {
  network_interface_id      = azurerm_network_interface.VMnicIPY.id
  network_security_group_id = azurerm_network_security_group.SecuritygroupIPY.id
 }
