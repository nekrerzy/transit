variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "component" {
  description = "Component name for naming convention"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "Region code (uaen, uaec, etc.)"
  type        = string
}

variable "sequence" {
  description = "Sequence number for naming"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# Key Vault Configuration
variable "sku_name" {
  description = "SKU name for Key Vault (standard or premium)"
  type        = string
  default     = "premium"
  
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "managed_identity_object_id" {
  description = "Object ID of managed identity for CMK access (optional)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for Key Vault (optional)"
  type        = string
  default     = null
}

variable "create_application_key" {
  description = "Whether to create an example application encryption key (requires private access)"
  type        = bool
  default     = false
}

variable "additional_rbac_assignments" {
  description = "Additional RBAC role assignments for users/groups"
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = {}
}