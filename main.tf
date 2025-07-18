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

# PostgreSQL module - RE-ENABLED FOR TESTING
# Previous Azure InternalServerError may have been resolved
module "postgresql" {
  source = "./modules/postgresql"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  subscription_id            = var.subscription_id
  postgres_subnet_cidr        = var.postgres_subnet_cidr
  private_endpoint_subnet_id  = var.private_endpoint_subnet_id
  private_dns_zone_id         = var.postgresql_private_dns_zone_id
  network_resource_group_name = "rg-network-dev-incp-uaen-001"
  virtual_network_name        = "vnet-bain-dev-incp-uaen-001"
  # admin_password auto-generated in module
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
}

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

# AKS module - RE-ENABLED FOR TESTING WITH POSTGRESQL
# Updated per Mohamed Soliman: Using null DNS zone (existing hub virtual link)
# AKS uses SystemAssigned identity and fixed service CIDR
module "aks" {
  source = "./modules/aks"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.aks_private_dns_zone_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  aks_subnet_id              = var.aks_subnet_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
}

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

# Azure OpenAI module - BLOCKED BY ORGANIZATIONAL NSP
# Error: NetworkSecurityPerimeterTrafficDenied at subscription/org level
# Requires security team approval - see message sent to security team
# 
# module "openai" {
#   source = "./modules/openai"
#   
#   resource_group_name        = azurerm_resource_group.main.name
#   location                  = azurerm_resource_group.main.location
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   component                 = var.component
#   environment               = var.environment
#   region                    = var.region
#   sequence                  = var.sequence
#   
#   tags = var.common_tags
# }