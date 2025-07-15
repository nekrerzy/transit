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

variable "postgresql_delegated_subnet_id" {
  description = "Subnet ID for PostgreSQL delegation"
  type        = string
}

variable "postgresql_private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL"
  type        = string
}

variable "postgresql_admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "UAE North"
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