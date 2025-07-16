output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_tenant_id" {
  description = "Tenant ID of the Key Vault"
  value       = azurerm_key_vault.main.tenant_id
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.keyvault.id
}

output "private_endpoint_ip" {
  description = "Private IP address of the Key Vault"
  value       = azurerm_private_endpoint.keyvault.private_service_connection[0].private_ip_address
}

output "application_key_id" {
  description = "ID of the application encryption key (if created)"
  value       = var.create_application_key ? azurerm_key_vault_key.application_key[0].id : null
}

output "application_key_name" {
  description = "Name of the application encryption key (if created)"
  value       = var.create_application_key ? azurerm_key_vault_key.application_key[0].name : null
}

output "access_policy_ids" {
  description = "IDs of all access policies created"
  value = {
    terraform = azurerm_key_vault_access_policy.terraform.id
    managed_identity = var.managed_identity_object_id != null ? azurerm_key_vault_access_policy.managed_identity[0].id : null
    additional = { for k, v in azurerm_key_vault_access_policy.additional : k => v.id }
  }
}