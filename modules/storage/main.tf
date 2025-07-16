data "azurerm_client_config" "current" {}

# Random string for storage account name uniqueness
resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

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

# Key for storage account encryption in existing Key Vault
resource "azurerm_key_vault_key" "storage_key" {
  name         = "key-storage-${var.storage_purpose}-${var.component}-${var.environment}-${var.sequence}"
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

# Storage account with CMK encryption and no access keys
resource "azurerm_storage_account" "main" {
  name                = "st${var.storage_purpose}${var.environment}incp${var.region}${random_string.storage_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "ZRS" # Zone-redundant storage
  account_kind             = "StorageV2"

  # Security settings
  public_network_access_enabled     = false
  shared_access_key_enabled         = false # No access keys
  allow_nested_items_to_be_public   = false
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true # Required by policy
  allowed_copy_scope                = "AAD" # Required by policy

  # CMK encryption for all services
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage_key.id
    managed_hsm_key_id        = null
    user_assigned_identity_id = data.azurerm_user_assigned_identity.existing.id
  }

  # Table service encryption with CMK
  table_encryption_key_type = "Account"
  
  # Queue service encryption with CMK  
  queue_encryption_key_type = "Account"

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["None"] # Restrict bypass as required by policy
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_key.storage_key
  ]
}

# Private endpoint for storage account blob service
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-${azurerm_storage_account.main.name}-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.main.name}-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Key Vault private endpoint already exists in security RG - no need to create