# Documentación de Despliegue con Terraform en Azure

Este proyecto utiliza Terraform para desplegar dos componentes en Azure:
1. **Azure Function App** con Node.js
2. **Máquina Virtual Linux**

## Requisitos Previos

Antes de ejecutar los scripts, asegúrate de tener lo siguiente:
- Cuenta en **Microsoft Azure** con permisos para crear recursos.
- **Azure CLI** instalado y autenticado (`az login`).
- **Terraform** instalado.

---

# Parte 1: Despliegue de una Azure Function

## Archivos Principales

### **main.tf**
Define los recursos para desplegar una Function App en Azure:

#### **Provider**
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```
Especifica el proveedor de Azure y la suscripción donde se crearán los recursos.

#### **Grupo de Recursos**
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.name_function
  location = var.location
}
```
Crea un **Resource Group** en la ubicación definida.

#### **Storage Account**
```hcl
resource "azurerm_storage_account" "sa" {
  name                     = var.name_function
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```
Crea una cuenta de almacenamiento necesaria para el Function App.

#### **Service Plan**
```hcl
resource "azurerm_service_plan" "sp" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "Y1"
}
```
Define un plan de servicio con el SKU de consumo (`Y1`).

#### **Function App**
```hcl
resource "azurerm_windows_function_app" "wfa" {
  name                = var.name_function
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      node_version = "~18"
    }
  }
}
```
Crea una **Azure Function App** basada en Node.js versión 18.

#### **Función dentro de la Function App**
```hcl
resource "azurerm_function_app_function" "faf" {
  name            = var.name_function
  function_app_id = azurerm_windows_function_app.wfa.id
  language        = "Javascript"
  file {
    name    = "index.js"
    content = file("example/index.js")
  }
  test_data = jsonencode({ "name" = "Azure" })
  config_json = jsonencode({
    "bindings": [
      {
        "authLevel": "anonymous",
        "type": "httpTrigger",
        "direction": "in",
        "name": "req",
        "methods": ["get", "post"]
      },
      {
        "type": "http",
        "direction": "out",
        "name": "res"
      }
    ]
  })
}
```
Configura una función HTTP anónima con métodos `GET` y `POST`.

### **variables.tf**
Define variables reutilizables:
```hcl
variable "name_function" {
  type        = string
  description = "Name Function"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Location"
}
```

### **output.tf**
Muestra la URL de la Function App:
```hcl
output "function_app_url" {
  value = azurerm_windows_function_app.wfa.default_hostname
}
```

---

# Ejecución

1. Inicializar Terraform:
   ```sh
   terraform init
   ```
2. Validar la configuración:
   ```sh
   terraform validate
   ```
3. Ver el plan de ejecución:
   ```sh
   terraform plan
   ```
4. Aplicar los cambios:
   ```sh
   terraform apply
   ```

   ![image](https://github.com/user-attachments/assets/476714b3-762a-4b75-b263-efd6995a09b7)


   Podemos verificar entrando al link proporcionado por azure, en mi caso: https://dmontezumanew.azurewebsites.net/api/dmontezumanew

   ![image](https://github.com/user-attachments/assets/7b9bfb3e-6eca-482e-960d-dfd55826ef3e)



6. Destruir los recursos si es necesario:
   ```sh
   terraform destroy
   ```

# Parte 2: Despliegue de una Máquina Virtual Linux

## Archivos Principales

### **main.tf**

#### **Grupo de Recursos**
```hcl
resource "azurerm_resource_group" "miprimeravmrg" {
  name     = var.resource_group
  location = var.location
}
```

#### **Red y Subred**
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "miprimeravmvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.miprimeravmrg.location
  resource_group_name = azurerm_resource_group.miprimeravmrg.name
}
```
Crea una red virtual en Azure.

```hcl
resource "azurerm_subnet" "subnet" {
  name                 = "miprimeravmsubnet"
  resource_group_name  = azurerm_resource_group.miprimeravmrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
```
Define la subred para la máquina virtual.

#### **Máquina Virtual Linux**
```hcl
resource "azurerm_linux_virtual_machine" "miprimeravm" {
  name                = "miprimeravm"
  resource_group_name = azurerm_resource_group.miprimeravmrg.name
  location            = azurerm_resource_group.miprimeravmrg.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

### **variables.tf**
```hcl
variable "resource_group" {}
variable "location" {
  default = "West Europe"
}
variable "admin_username" {}
variable "admin_password" {}
```

### **output.tf**
```hcl
output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
```

---

# Ejecución

1. Inicializar Terraform:
   ```sh
   terraform init
   ```
2. Validar la configuración:
   ```sh
   terraform validate
   ```
3. Ver el plan de ejecución:
   ```sh
   terraform plan
   ```
4. Aplicar los cambios:
   ```sh
   terraform apply
   ```

   Podemos verificar conectandonos a la maquina virtual usando ssh:
   ![image](https://github.com/user-attachments/assets/a61007e9-f820-4311-a26c-c7b1ac73057a)

6. Destruir los recursos si es necesario:
   ```sh
   terraform destroy
   ```

   # Parte 3: Despliegue de una Máquina virtual en Linux usando módulos

   Este proyecto utiliza Terraform para desplegar una máquina virtual Linux en Microsoft Azure. La infraestructura está organizada en módulos para facilitar su reutilización y mantenimiento. El módulo vm define     los recursos de red y la máquina virtual, mientras que la configuración principal gestiona el grupo de recursos, la red virtual y la subred.


   # **Requisitos Previos**

    - Cuenta activa en Microsoft Azure.

    - Terraform instalado.

    - Configuración de credenciales de Azure.

    - Descripción de Archivos

    # **1. Módulo VM (modules/vm)**
    
    Este módulo define la configuración de la máquina virtual, incluyendo la red y la seguridad.
    
    **main.tf**
    
    - Crea una interfaz de red (azurerm_network_interface).
    
    - Crea una dirección IP pública (azurerm_public_ip).
    
    - Asocia una máquina virtual Linux (azurerm_linux_virtual_machine).
    
    - Configura un grupo de seguridad (azurerm_network_security_group) con reglas para SSH y Ansible.
    
    **variables.tf**
    
    - Define las variables necesarias, como el nombre de la VM, la ubicación, credenciales de acceso y configuración de red.
    
    **outputs.tf**
    
    - Expone la dirección IP pública de la máquina virtual.
    
    # **2. Configuración Principal (./)**
    
    **main.tf**
    
    - Define el provider de Azure.
    
    - Crea el grupo de recursos.
    
    - Configura la red virtual y la subred.
    
    - Invoca el módulo vm con las variables adecuadas.
    
    **variables.tf**
    
    - Define las variables globales del proyecto, como la suscripción de Azure y la configuración de red.
    
    **Despliegue**
    
    - Inicializar Terraform: terraform init
    
    - Planificar la infraestructura: terraform validate
    
    - Aplicar la configuración: terraform apply


      ![image](https://github.com/user-attachments/assets/1d00a9bc-bb85-4589-987a-e45d5eb3cacc)

      ![image](https://github.com/user-attachments/assets/5530cd76-0ce7-4ca0-88ae-8682ac6464d0)

    
    **Eliminación de Recursos**
    
    - Para eliminar la infraestructura creada: terraform destroy