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

variable "gpt41_capacity" {
  description = "Capacity for GPT-4.1 deployment (TPM in thousands)"
  type        = number
  default     = 30
}

variable "embedding_capacity" {
  description = "Capacity for text embedding deployment (TPM in thousands)"
  type        = number
  default     = 30
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

# NSP-related variables temporarily removed for simplified deployment