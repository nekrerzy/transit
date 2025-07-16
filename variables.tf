variable "component" {
  description = "Component name for naming convention"
  type        = string
  default     = "app"
}

variable "environment" {
  description = "Environment (dev, prod, test)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "prod", "test"], var.environment)
    error_message = "Environment must be dev, prod, or test."
  }
}

variable "region" {
  description = "Azure region code for naming (uaen for UAE North)"
  type        = string
  default     = "uaen"
}

variable "sequence" {
  description = "Sequence number for naming"
  type        = string
  default     = "001"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints (required due to security policies)"
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual Network ID for private DNS zone linking"
  type        = string
}

variable "postgres_subnet_cidr" {
  description = "CIDR block for PostgreSQL subnet"
  type        = string
  default     = "172.20.161.0/28"
}

variable "postgresql_private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL"
  type        = string
}

# postgresql_admin_password removed - using random_password resource instead

variable "location" {
  description = "Azure region"
  type        = string
  default     = "UAE North"
}

# AKS Configuration
variable "aks_private_dns_zone_id" {
  description = "Private DNS zone ID for AKS private cluster. Use 'System' to let AKS manage it automatically, or provide a custom private DNS zone ID"
  type        = string
  default     = "System"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for AKS monitoring"
  type        = string
}

variable "aks_subnet_id" {
  description = "Existing AKS subnet ID for all node pools"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "bain"
    ManagedBy   = "terraform"
  }
}

variable "storage_accounts" {
  description = "Map of storage accounts to create with different purposes"
  type = map(object({
    purpose   = string
    data_type = string
  }))
  default = {
    general = {
      purpose   = "General application storage"
      data_type = "Application"
    }
    ragdata = {
      purpose   = "RAG data and embeddings storage"
      data_type = "AI/ML"
    }
    logs = {
      purpose   = "Application logs and diagnostics"
      data_type = "Logs"
    }
  }
}

variable "key_vaults" {
  description = "Map of Key Vaults to create with different purposes"
  type = map(object({
    purpose                   = string
    sku_name                 = optional(string, "premium")
    create_application_key   = optional(bool, false)
  }))
  default = {
    app-secrets = {
      purpose                 = "Application secrets and configurations"
      sku_name               = "premium"
      create_application_key = false
    }
    ai-keys = {
      purpose                 = "AI/ML model keys and tokens"
      sku_name               = "premium"
      create_application_key = false
    }
    certificates = {
      purpose                 = "SSL certificates and PKI"
      sku_name               = "premium"
      create_application_key = false
    }
  }
}