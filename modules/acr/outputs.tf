output "container_registry_id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.main.id
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.main.name
}

output "container_registry_login_server" {
  description = "Login server URL of the container registry"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_admin_enabled" {
  description = "Whether admin account is enabled"
  value       = azurerm_container_registry.main.admin_enabled
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.acr.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the container registry"
  value       = azurerm_private_endpoint.acr.private_service_connection[0].private_ip_address
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone (managed by Azure Policy)"
  value       = null
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone (managed by Azure Policy)"
  value       = "privatelink.azurecr.io"
}

output "key_vault_id" {
  description = "ID of the Key Vault used for encryption"
  value       = data.azurerm_key_vault.existing.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault used for encryption"
  value       = data.azurerm_key_vault.existing.vault_uri
}

output "managed_identity_id" {
  description = "ID of the managed identity used for encryption"
  value       = data.azurerm_user_assigned_identity.existing.id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity used for encryption"
  value       = data.azurerm_user_assigned_identity.existing.client_id
}

output "encryption_key_id" {
  description = "ID of the encryption key"
  value       = azurerm_key_vault_key.acr_key.id
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.resource_group_name
}