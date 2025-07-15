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

# PostgreSQL outputs
output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.postgresql.postgresql_server_name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.postgresql.postgresql_server_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.postgresql.database_name
}

output "postgresql_admin_password" {
  description = "Generated PostgreSQL admin password"
  value       = module.postgresql.admin_password
  sensitive   = true
}

# Azure Search outputs
output "search_service_name" {
  description = "Name of the Azure Search service"
  value       = module.search.search_service_name
}

output "search_service_url" {
  description = "URL of the Azure Search service"
  value       = module.search.search_service_url
}

# Redis outputs
output "redis_cache_name" {
  description = "Name of the Redis cache"
  value       = module.redis.redis_cache_name
}

output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = module.redis.redis_hostname
}

output "redis_primary_access_key" {
  description = "Primary access key for Redis"
  value       = module.redis.redis_primary_access_key
  sensitive   = true
}