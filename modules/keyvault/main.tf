# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Key Vault with enterprise security
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.component}${var.environment}${var.region}${var.sequence}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  # Enterprise security settings
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90

  # Enable RBAC authorization (required by Azure Policy)
  enable_rbac_authorization = true

  # Network access restrictions
  public_network_access_enabled = false
  
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    
    # Allow access from specific virtual networks if provided
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# RBAC role assignment for the current service principal (Key Vault Administrator)
resource "azurerm_role_assignment" "terraform_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# RBAC role assignment for managed identity (Key Vault Crypto Service Encryption User)
resource "azurerm_role_assignment" "managed_identity" {
  count = var.managed_identity_object_id != null ? 1 : 0
  
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = var.managed_identity_object_id
}

# Additional RBAC role assignments for specific users/groups
resource "azurerm_role_assignment" "additional" {
  for_each = var.additional_rbac_assignments

  scope                = azurerm_key_vault.main.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

# Private endpoint for Key Vault
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-${azurerm_key_vault.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.main.name}"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Private DNS zone integration (if specified)
resource "azurerm_private_dns_a_record" "keyvault" {
  count = var.private_dns_zone_id != null ? 1 : 0
  
  name                = azurerm_key_vault.main.name
  zone_name           = split("/", var.private_dns_zone_id)[8]
  resource_group_name = split("/", var.private_dns_zone_id)[4]
  ttl                 = 300
  records             = [azurerm_private_endpoint.keyvault.private_service_connection[0].private_ip_address]

  tags = var.tags
}

# Example encryption key for applications to use
resource "azurerm_key_vault_key" "application_key" {
  count = var.create_application_key ? 1 : 0
  
  name         = "key-${var.component}${var.environment}${var.sequence}"
  key_vault_id = azurerm_key_vault.main.id
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

  depends_on = [azurerm_role_assignment.terraform_admin]
}