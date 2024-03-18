

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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record

resource "azurerm_dns_zone" "dns-public-vm" {
  name                = "ipypodmancp2.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "dnsvmrecord" {
  name                = "dnsvm"
  zone_name           = azurerm_dns_zone.dns-public-vm.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.PublicipIPY.id
}



resource "azurerm_resource_group" "lbrg" {
  name     = "LoadBalancerRG"
  location = azurerm_resource_group.rg.location
}

# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "publiciplb" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record

#resource "azurerm_dns_zone" "dns-public-aks" {
#  name                = "ipynginxcp2.com"
#  resource_group_name = azurerm_resource_group.rg.name
#}
#
#resource "azurerm_dns_a_record" "dnsaksrecord" {
#  name                = "dnsaks"
#  zone_name           = azurerm_dns_zone.dns-public-aks.name
#  resource_group_name = azurerm_resource_group.rg.name
#  ttl                 = 300
#  target_resource_id  = azurerm_public_ip.publiciplb.id
#}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb

resource "azurerm_lb" "azurelb" {
  name                = "AksLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddressLB"
    public_ip_address_id = azurerm_public_ip.publiciplb.id
  }
}





resource "terraform_data" "azlogin" {

  provisioner "local-exec" {
    command = "az login --service-principal -u 26871334-6dde-4994-8980-0c2dddb877ec -p tX~8Q~jrIzVtn7v73oQwGJmXYWUfr41RjF.9Aanb --tenant 899789dc-202f-44b4-8472-a6d40f9eb440"
  }
}

# https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on

resource "terraform_data" "kubeconfig" {
  depends_on =  [azurerm_kubernetes_cluster.k8s]
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group rg_cp2 --name clusteraks"
  }
}



# Creamos el servicio de k8s

#provider "kubernetes" {
#  config_path = "~/.kube/config"
#}
#
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume

#resource "kubernetes_persistent_volume" "k8svolumenpersistente" {
#  depends_on =  [azurerm_kubernetes_cluster.k8s]
#  metadata {
#    name = "k8svolumenpersistente"
#  }
#  spec {
#    capacity = {
#      storage = "1Gi"
#    }
#    access_modes = ["ReadWriteOnce"]
#    persistent_volume_source {
#      azure_disk {
#        caching_mode  = "None"
#        data_disk_uri = azurerm_managed_disk.azureidiscogestionado.id
#        disk_name     = "discoaks"
#        kind          = "Managed"
#      }
#    }
#  }
#}


resource "azurerm_managed_disk" "azureidiscogestionado" {
  name                 = "discoazuregestionado"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  tags = {
    environment = azurerm_resource_group.rg.name
  }
}


output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

data "azurerm_public_ip" "PublicipIPY" {
  name                = azurerm_public_ip.PublicipIPY.name
  resource_group_name = azurerm_linux_virtual_machine.VMIPYDevops.resource_group_name
}

output "public_ip_address_vm" {
  value = data.azurerm_public_ip.PublicipIPY.ip_address
}

data "azurerm_public_ip" "publiciplb" {
  name                = azurerm_public_ip.publiciplb.name
  resource_group_name = azurerm_lb.azurelb.resource_group_name
}


output "public_ip_address_lb" {
  value = data.azurerm_public_ip.publiciplb.ip_address
}
