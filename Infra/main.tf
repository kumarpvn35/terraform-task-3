terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}


module "rg" {
  source   = "./modules/resource_group"
  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location
}

resource "azurerm_kubernetes_cluster" "cluster" {
  resource_group_name = "resource_group_1"
  location            = "central india"
  name                = "testaks"
  default_node_pool {
    name       = "defaultpool"
    vm_size    = "Standard_D4s_v3"
    node_count = 2
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  identity {
    type = "SystemAssigned"
  }
  dns_prefix                = "exampleaks1"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  depends_on                = [module.rg]
}


resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry8025"
  resource_group_name = "resource_group_1"
  location            = "central india"
  sku                 = "Basic"
  admin_enabled       = false
}

data "azuread_service_principal" "sp" {
  client_id = "f903cbb2-ca50-485a-9c09-08e5444654fd"
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


resource "azurerm_role_assignment" "aks_acr_pull_sp" {
  principal_id                     = data.azuread_service_principal.sp.object_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}