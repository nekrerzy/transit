variable "resource_group_name" {
  description = "Name of the resource group to use"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "component" {
  description = "Component name for naming convention"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, test)"
  type        = string
}

variable "region" {
  description = "Azure region code (uaen)"
  type        = string
}

variable "sequence" {
  description = "Sequence number for naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints (required for this security model)"
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual Network ID for private DNS zone linking"
  type        = string
}

variable "sku" {
  description = "SKU for the container registry"
  type        = string
  default     = "Premium"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for high availability"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Number of days to retain untagged manifests"
  type        = number
  default     = 30
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for ACR"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic logs"
  type        = string
  default     = null
}

variable "network_resource_group_name" {
  description = "Network resource group name for DNS zones"
  type        = string
  default     = "rg-network-dev-incp-uaen-001"
}