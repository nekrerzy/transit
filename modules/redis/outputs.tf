output "redis_cache_id" {
  description = "ID of the Redis cache"
  value       = azurerm_redis_cache.main.id
}

output "redis_cache_name" {
  description = "Name of the Redis cache"
  value       = azurerm_redis_cache.main.name
}

output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = azurerm_redis_cache.main.hostname
}

output "redis_port" {
  description = "Port of the Redis cache"
  value       = azurerm_redis_cache.main.port
}

output "redis_ssl_port" {
  description = "SSL port of the Redis cache"
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_primary_access_key" {
  description = "Primary access key for Redis"
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.redis.id
}