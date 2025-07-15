data "azurerm_client_config" "current" {}

# Random string for storage account name uniqueness
resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Key Vault for CMK (Customer Managed Keys)
resource "azurerm_key_vault" "storage_kv" {
  name                = "kv-${var.component}-${var.environment}-${var.region}-${var.sequence}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7

  public_network_access_enabled = false
  enable_rbac_authorization     = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Key for storage account encryption
resource "azurerm_key_vault_key" "storage_key" {
  name         = "key-storage-${var.component}-${var.environment}"
  key_vault_id = azurerm_key_vault.storage_kv.id
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

  depends_on = [azurerm_key_vault.storage_kv]
}

# Storage account with CMK encryption and no access keys
resource "azurerm_storage_account" "main" {
  name                = "st${var.component}${var.environment}incp${var.region}${random_string.storage_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "ZRS" # Zone-redundant storage
  account_kind             = "StorageV2"

  # Security settings
  public_network_access_enabled   = false
  shared_access_key_enabled       = false # No access keys
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true

  # CMK encryption
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage_key.id
    managed_hsm_key_id        = null
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_key.storage_key,
    azurerm_role_assignment.storage_kv_crypto
  ]
}

# Managed Identity for storage account
resource "azurerm_user_assigned_identity" "storage" {
  name                = "id-storage-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role assignment for storage account to access Key Vault
resource "azurerm_role_assignment" "storage_kv_crypto" {
  scope                = azurerm_key_vault.storage_kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
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

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.network_resource_group_name
  tags                = var.tags
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = "kv-dns-link"
  resource_group_name   = var.network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "kv" {
  name                = "pe-${azurerm_key_vault.storage_kv.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.storage_kv.name}"
    private_connection_resource_id = azurerm_key_vault.storage_kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.kv]
}