output "acr_name" {
  description = "Azure Container Registry resource name"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "aks_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.cluster.name
}

output "aks_resource_group_name" {
  description = "AKS resource group name"
  value       = azurerm_kubernetes_cluster.cluster.resource_group_name
}