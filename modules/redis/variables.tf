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

variable "capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 2
}

variable "family" {
  description = "Redis cache family"
  type        = string
  default     = "C"
}

variable "sku_name" {
  description = "Redis cache SKU"
  type        = string
  default     = "Standard"
}

variable "maxmemory_reserved" {
  description = "Maximum memory reserved for Redis"
  type        = number
  default     = 512
}

variable "maxmemory_delta" {
  description = "Maximum memory delta for Redis"
  type        = number
  default     = 512
}

variable "maxmemory_policy" {
  description = "Maximum memory policy for Redis"
  type        = string
  default     = "allkeys-lru"
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}