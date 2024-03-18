
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Definimos el proveedor y su version

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}


# Creamos el servicio principal

provider "azurerm" {
	# Configuration options
	features {}
	subscription_id = "cda335bf-ab3b-46d2-a3a0-df67c4f922c3"
	client_id		= "26871334-6dde-4994-8980-0c2dddb877ec"
	client_secret	= "tX~8Q~jrIzVtn7v73oQwGJmXYWUfr41RjF.9Aanb"
	tenant_id		= "899789dc-202f-44b4-8472-a6d40f9eb440"
	}

# Creación del recurso en Azure

resource "azurerm_resource_group" "rg" {
  name     = "rg_cp2"
  location = var.location
  
	tags = {
	enviroment = "casopractico2"
	}
  
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = "clusteraks"
  resource_group_name = "rg_cp2"
  dns_prefix          = "clusteraksdns"

  default_node_pool {
    name       = "agenteaks"
    vm_size    = "Standard_D2_v2"
	node_count = 1
  }

  #node_resource_group = azurerm_resource_group.rg.name

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "casopractico2"
  }
}




resource "azurerm_container_registry" "acr" {
  name                = "UnirContainerIPY"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
  georeplications {
    location                = "East US"
    zone_redundancy_enabled = true

  }
  georeplications {
    location                = "North Europe"
    zone_redundancy_enabled = true

  }
}





# Salida de ACR Login server

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# Salida de ACR username

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

# Salida de ACR password

output "acr_admin_password" {
  value = azurerm_container_registry.acr.admin_password
  sensitive = true
}

# Generamos el fichero "auth.json"

resource "local_file" "output_file" {
  content = <<-EOF
    ACR Login Server: ${azurerm_container_registry.acr.login_server}
    ACR Admin Username: ${azurerm_container_registry.acr.admin_username}
    ACR Admin Password: ${azurerm_container_registry.acr.admin_password}
  EOF
  filename = "/etc/containers/auth.json"
}

resource "local_file" "container_pass" {
  content = <<-EOF
${azurerm_container_registry.acr.admin_password}
  EOF
  filename = "/etc/containers/container_pass"
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}



resource "exportssh" "sshvm" {
  provisioner "local-exec" {
    command = "terraform output -raw ssh_private_key > /root/.ssh/vm_azure_devops"
  }
}


resource "exportssh" "modsshvm" {
  provisioner "local-exec" {
    command = "chmod 600  /root/.ssh/vm_azure_devops"
  }
}
