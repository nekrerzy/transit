output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account.storage_account_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault used for CMK"
  value       = module.storage_account.key_vault_uri
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.storage_account.resource_group_name
}