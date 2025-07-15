# Azure OpenAI Service with enterprise security
resource "azurerm_cognitive_account" "openai" {
  name                           = "oai-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  kind                           = "OpenAI"
  sku_name                      = "S0"
  public_network_access_enabled = false
  outbound_network_access_restricted = true  # Required by policy
  
  # CMK encryption using existing Key Vault
  customer_managed_key {
    key_vault_key_id   = azurerm_key_vault_key.openai_key.id
    identity_client_id = data.azurerm_user_assigned_identity.existing.client_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  tags = var.tags
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

# Key for OpenAI encryption in existing Key Vault
resource "azurerm_key_vault_key" "openai_key" {
  name         = "key-openai-${var.component}-${var.environment}-${var.sequence}"
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

# GPT-4.1 model deployment (latest 2025 version)
resource "azurerm_cognitive_deployment" "gpt41" {
  name                 = "gpt-41"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-41"
    version = "2025-01-31"
  }

  sku {
    name     = "Standard"
    capacity = var.gpt41_capacity
  }
}

# Text Embedding 3 Large model deployment
resource "azurerm_cognitive_deployment" "text_embedding_3_large" {
  name                 = "text-embedding-3-large"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "text-embedding-3-large"
    version = "1"
  }

  sku {
    name     = "Standard"
    capacity = var.embedding_capacity
  }
}

# Private endpoint for OpenAI
resource "azurerm_private_endpoint" "openai" {
  name                = "pe-${azurerm_cognitive_account.openai.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_cognitive_account.openai.name}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  tags = var.tags
}