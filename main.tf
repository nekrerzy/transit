terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Set your subscription ID here
  subscription_id = var.subscription_id
}

# Data sources
data "azurerm_client_config" "current" {}

# Main resource group for all resources
resource "azurerm_resource_group" "main" {
  name     = "rg-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  location = var.location
  tags     = var.common_tags
}

# Storage accounts for different purposes
module "storage_accounts" {
  source = "./modules/storage"
  
  for_each = var.storage_accounts
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  virtual_network_id         = var.virtual_network_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  # Override purpose for naming
  storage_purpose = each.key
  
  tags = merge(var.common_tags, {
    Purpose = each.value.purpose
    DataType = each.value.data_type
  })
}

# PostgreSQL module - TEMPORARILY COMMENTED OUT (Azure internal server error)
# Error: InternalServerError during PostgreSQL deployment 
# Tracking ID: 6099a468-377a-4fa5-a951-6f42842004c5
# Will re-enable after Azure service issue is resolved
#
# module "postgresql" {
#   source = "./modules/postgresql"
#   
#   resource_group_name         = azurerm_resource_group.main.name
#   location                   = azurerm_resource_group.main.location
#   subscription_id            = var.subscription_id
#   postgres_subnet_cidr        = var.postgres_subnet_cidr
#   private_endpoint_subnet_id  = var.private_endpoint_subnet_id
#   private_dns_zone_id         = var.postgresql_private_dns_zone_id
#   network_resource_group_name = "rg-network-dev-incp-uaen-001"
#   virtual_network_name        = "vnet-bain-dev-incp-uaen-001"
#   # admin_password auto-generated in module
#   component                  = var.component
#   environment                = var.environment
#   region                     = var.region
#   sequence                   = var.sequence
#   
#   tags = var.common_tags
# }

# Azure Search module
module "search" {
  source = "./modules/search"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
}

# Redis module
module "redis" {
  source = "./modules/redis"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
}

# Key Vaults for different purposes
module "key_vaults" {
  source = "./modules/keyvault"
  
  for_each = var.key_vaults
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  # Override purpose for naming
  kv_purpose = each.key
  sku_name = each.value.sku_name
  create_application_key = each.value.create_application_key
  
  tags = merge(var.common_tags, {
    Purpose = each.value.purpose
    KeyVaultType = each.key
  })
}

# AKS module - BLOCKED BY DNS CONFIGURATION IN HUB-AND-SPOKE ARCHITECTURE
# Error: VMExtensionError_K8SAPIServerDNSLookupFail
# Root cause: Custom DNS servers in hub-and-spoke cannot resolve AKS API server private DNS
# Requires network team to configure DNS forwarders for *.privatelink.*.azmk8s.io zones
# See AKS_DNS_ISSUE.md for detailed troubleshooting and network requirements
# 
# module "aks" {
#   source = "./modules/aks"
#   
#   resource_group_name         = azurerm_resource_group.main.name
#   location                   = azurerm_resource_group.main.location
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_id        = var.aks_private_dns_zone_id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#   aks_subnet_id              = var.aks_subnet_id
#   component                  = var.component
#   environment                = var.environment
#   region                     = var.region
#   sequence                   = var.sequence
#   
#   tags = var.common_tags
# }

# Azure Container Registry module
module "acr" {
  source = "./modules/acr"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  virtual_network_id         = var.virtual_network_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  # Optional: Enable diagnostics with Log Analytics
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  tags = var.common_tags
}

# Azure OpenAI module - TESTING FOR NSP RESTRICTIONS
# Previous error: NetworkSecurityPerimeterTrafficDenied 
# Re-enabling to test current NSP configuration
module "openai" {
  source = "./modules/openai"
  
  resource_group_name            = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  private_endpoint_subnet_id    = var.private_endpoint_subnet_id
  subscription_id               = var.subscription_id
  vnet_address_space           = "172.20.160.0/24"
  private_endpoint_subnet_cidr = "172.20.160.128/25"
  component                    = var.component
  environment                  = var.environment
  region                       = var.region
  sequence                     = var.sequence
  
  tags = var.common_tags
}