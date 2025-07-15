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

# Storage account module
module "storage_account" {
  source = "./modules/storage"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  virtual_network_id         = var.virtual_network_id
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
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

# AKS module
module "aks" {
  source = "./modules/aks"
  
  resource_group_name         = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  virtual_network_id         = var.virtual_network_id
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.aks_private_dns_zone_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  aks_system_subnet_cidr     = var.aks_system_subnet_cidr
  aks_api_subnet_cidr        = var.aks_api_subnet_cidr
  aks_user_subnet_cidr       = var.aks_user_subnet_cidr
  aks_vllm_subnet_cidr       = var.aks_vllm_subnet_cidr
  component                  = var.component
  environment                = var.environment
  region                     = var.region
  sequence                   = var.sequence
  
  tags = var.common_tags
}

# Azure OpenAI module - COMMENTED OUT DUE TO NETWORK SECURITY PERIMETER RESTRICTIONS
# Error: NetworkSecurityPerimeterTrafficDenied - outbound request denied by NetworkSecurityPerimeter
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