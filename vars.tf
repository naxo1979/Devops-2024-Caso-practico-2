

# https://learn.microsoft.com/en-us/azure/media-services/latest/azure-regions-code-names
# Definimos la localizacion
# az vm list-sizes --location westeurope

variable "location" {
	type = string
	description = "Región de Azure donde será creada la infraestructura"
	default = "uksouth"
}


# Especificamos los parámetros de nuesta VM
	
variable "vm_size" {
	type = string
	description = "Características de la VM, CPU y RAM"
	default = "Standard_DS2_v2"
}
