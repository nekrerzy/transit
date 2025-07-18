output "postgresql_server_id" {
  description = "ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgresql_admin_username" {
  description = "Administrator username"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
  sensitive   = true
}

# Private endpoint outputs
output "private_endpoint_ip" {
  description = "Private IP address of the PostgreSQL private endpoint"
  value       = azurerm_private_endpoint.postgres.private_service_connection[0].private_ip_address
}

output "private_endpoint_id" {
  description = "ID of the PostgreSQL private endpoint"
  value       = azurerm_private_endpoint.postgres.id
}

# Database name output - COMMENTED OUT (optional database disabled)
# output "database_name" {
#   description = "Name of the created database"
#   value       = var.create_sample_database ? azurerm_postgresql_flexible_server_database.example[0].name : null
# }

output "admin_password" {
  description = "Generated administrator password"
  value       = random_password.postgres_admin.result
  sensitive   = true
}