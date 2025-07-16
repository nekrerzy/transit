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
  features {}
  
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

# PostgreSQL module
module "postgresql" {
  source = "./modules/postgresql"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  subscription_id            = var.subscription_id
  postgres_subnet_cidr       = var.postgres_subnet_cidr
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.postgresql_private_dns_zone_id
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

# AKS module - COMMENTED OUT DUE TO AZURE FIREWALL CONFIGURATION ISSUE
# Error: VMExtensionError_OutBoundConnFail - nodes cannot establish outbound connection
# Requires network team to configure Azure Firewall with AzureKubernetesService FQDN tag
# See AKS_FIREWALL_ISSUE.md for detailed troubleshooting steps
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

# Azure OpenAI module - STILL BLOCKED BY NETWORK SECURITY PERIMETER
# Error: NetworkSecurityPerimeterTrafficDenied - outbound request denied by NetworkSecurityPerimeter
# NSP restrictions remain in place as of $(date)
# Requires security team approval or provisioning through different process
# 
# module "openai" {
#   source = "./modules/openai"
#   
#   resource_group_name         = azurerm_resource_group.main.name
#   location                   = azurerm_resource_group.main.location
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   component                  = var.component
#   environment                = var.environment
#   region                     = var.region
#   sequence                   = var.sequence
#   
#   tags = var.common_tags
# }