# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Reference existing Key Vault from security RG for CMK
data "azurerm_key_vault" "existing" {
  name                = "kv-bain-dev-incp-uaen-01"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Reference existing managed identity from security RG for CMK
data "azurerm_user_assigned_identity" "existing" {
  name                = "id-storage-cmk-dev-incp-uaen-001"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Key for ACR encryption in existing Key Vault
resource "azurerm_key_vault_key" "acr_key" {
  name         = "key-acr-${var.component}-${var.environment}-${var.sequence}"
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

  # Prevent recreation due to expiration_date changes
  lifecycle {
    ignore_changes = [expiration_date]
  }

  tags = var.tags
}

# Azure Container Registry with enterprise security
resource "azurerm_container_registry" "main" {
  name                = "acr${var.component}${var.environment}incp${var.region}${var.sequence}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false # No admin account for security

  # Zone redundancy for high availability
  zone_redundancy_enabled = var.zone_redundancy_enabled

  # Network access restrictions
  public_network_access_enabled = false
  network_rule_bypass_option   = "AzureServices"

  # Data endpoint access
  data_endpoint_enabled = true
  
  # Export policy - explicitly disabled to satisfy Azure Policy
  export_policy_enabled = false

  # Identity for CMK
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  # Customer-managed key encryption
  encryption {
    key_vault_key_id   = azurerm_key_vault_key.acr_key.id
    identity_client_id = data.azurerm_user_assigned_identity.existing.client_id
  }

  tags = var.tags
}

# Private endpoint for ACR
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${azurerm_container_registry.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_container_registry.main.name}"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  # Private DNS zone group will be managed by Azure Policy
  # private_dns_zone_group {
  #   name                 = "dns-zone-group"
  #   private_dns_zone_ids = [data.azurerm_private_dns_zone.acr.id]
  # }

  tags = var.tags
}

# Private DNS zone will be managed by Azure Policy automatically

# Diagnostic settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr" {
  count              = var.enable_diagnostics ? 1 : 0
  name               = "diag-${azurerm_container_registry.main.name}"
  target_resource_id = azurerm_container_registry.main.id
  
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}