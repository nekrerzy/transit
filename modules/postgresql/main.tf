data "azurerm_client_config" "current" {}

# Reference existing Key Vault from security RG
data "azurerm_key_vault" "existing" {
  name                = "kv-bain-dev-incp-uaen-01"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Reference existing managed identity from security RG
data "azurerm_user_assigned_identity" "existing" {
  name                = "id-storage-cmk-dev-incp-uaen-001"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Key for PostgreSQL encryption in existing Key Vault
resource "azurerm_key_vault_key" "postgres_key" {
  name         = "key-postgres-${var.component}-${var.environment}-${var.sequence}"
  key_vault_id = data.azurerm_key_vault.existing.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# PostgreSQL Flexible Server with CMK encryption
resource "azurerm_postgresql_flexible_server" "main" {
  name                = "psql-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Server configuration
  version                      = "15"
  administrator_login          = var.admin_username
  administrator_password       = var.admin_password
  sku_name                    = var.sku_name
  storage_mb                  = var.storage_mb
  storage_tier                = "P30"
  backup_retention_days       = 35
  geo_redundant_backup_enabled = true

  # Security settings
  public_network_access_enabled = false
  
  # High availability
  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = var.standby_availability_zone
  }

  # CMK encryption
  customer_managed_key {
    key_vault_key_id                     = azurerm_key_vault_key.postgres_key.id
    primary_user_assigned_identity_id    = data.azurerm_user_assigned_identity.existing.id
    geo_backup_key_vault_key_id         = azurerm_key_vault_key.postgres_key.id
    geo_backup_user_assigned_identity_id = data.azurerm_user_assigned_identity.existing.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  # Network configuration
  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  # Maintenance window
  maintenance_window {
    day_of_week  = 0  # Sunday
    start_hour   = 2
    start_minute = 0
  }

  tags = var.tags

  depends_on = [azurerm_key_vault_key.postgres_key]
}

# Private endpoint for PostgreSQL
resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-${azurerm_postgresql_flexible_server.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_postgresql_flexible_server.main.name}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# PostgreSQL configuration for security
resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "all"
}

# Example database (optional)
resource "azurerm_postgresql_flexible_server_database" "example" {
  name      = "${var.component}_${var.environment}"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"

  count = var.create_sample_database ? 1 : 0
}