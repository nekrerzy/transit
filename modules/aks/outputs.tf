output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_cluster_private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.private_fqdn
}

output "aks_kube_config" {
  description = "Kubernetes configuration for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_identity" {
  description = "Identity configuration of the AKS cluster"
  value = {
    type         = azurerm_kubernetes_cluster.aks.identity[0].type
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  }
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

# Node Pool Information
output "system_node_pool_name" {
  description = "Name of the system node pool"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
}

output "user_apps_node_pool_name" {
  description = "Name of the user apps node pool"
  value       = azurerm_kubernetes_cluster_node_pool.user_apps.name
}

output "vllm_node_pool_name" {
  description = "Name of the VLLM node pool"
  value       = azurerm_kubernetes_cluster_node_pool.vllm.name
}

# Subnet Information
output "aks_system_subnet_id" {
  description = "ID of the AKS system subnet"
  value       = azapi_resource.aks_system_subnet.id
}

output "aks_api_subnet_id" {
  description = "ID of the AKS API subnet"
  value       = azapi_resource.aks_api_subnet.id
}

output "aks_user_subnet_id" {
  description = "ID of the AKS user apps subnet"
  value       = azapi_resource.aks_user_subnet.id
}

output "aks_vllm_subnet_id" {
  description = "ID of the AKS VLLM subnet"
  value       = azapi_resource.aks_vllm_subnet.id
}

# Security Information
output "disk_encryption_set_id" {
  description = "ID of the disk encryption set for AKS"
  value       = azurerm_disk_encryption_set.aks.id
}

output "aks_key_vault_key_id" {
  description = "ID of the Key Vault key used for AKS encryption"
  value       = azurerm_key_vault_key.aks_key.id
}