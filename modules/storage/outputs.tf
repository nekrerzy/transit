output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = data.azurerm_key_vault.existing.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = data.azurerm_key_vault.existing.vault_uri
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.resource_group_name
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = data.azurerm_user_assigned_identity.existing.id
}