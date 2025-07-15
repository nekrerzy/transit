variable "resource_group_name" {
  description = "Name of the resource group"
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

variable "admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "psqladmin"
}

# admin_password removed - using random_password resource instead

variable "sku_name" {
  description = "PostgreSQL SKU name"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
}

variable "standby_availability_zone" {
  description = "Availability zone for standby server"
  type        = string
  default     = "2"
}

variable "network_resource_group_name" {
  description = "Network resource group name"
  type        = string
  default     = "rg-network-dev-incp-uaen-001"
}

variable "virtual_network_name" {
  description = "Virtual network name"
  type        = string
  default     = "vnet-bain-dev-incp-uaen-001"
}

variable "postgres_subnet_cidr" {
  description = "CIDR block for PostgreSQL subnet"
  type        = string
  default     = "172.20.161.0/28"
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for PostgreSQL"
  type        = string
}

variable "create_sample_database" {
  description = "Whether to create a sample database"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}