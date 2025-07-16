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

# AKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.29"
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for AKS private cluster. Use 'System' to let AKS manage it automatically, or provide a custom private DNS zone ID"
  type        = string
  default     = "System"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
}

# Network Configuration
variable "dns_service_ip" {
  description = "DNS service IP for AKS cluster"
  type        = string
  default     = "172.20.0.10"
}

variable "service_cidr" {
  description = "Service CIDR for AKS cluster"
  type        = string
  default     = "172.20.0.0/16"
}

variable "aks_subnet_id" {
  description = "Existing AKS subnet ID for all node pools"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for node pools"
  type        = list(string)
  default     = ["1", "3"]
}

# System Node Pool Configuration
variable "system_node_count" {
  description = "Initial number of nodes in system pool"
  type        = number
  default     = 2
}

variable "system_min_count" {
  description = "Minimum number of nodes in system pool"
  type        = number
  default     = 1
}

variable "system_max_count" {
  description = "Maximum number of nodes in system pool"
  type        = number
  default     = 3
}

variable "system_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

# User Apps Node Pool Configuration
variable "user_node_count" {
  description = "Initial number of nodes in user apps pool"
  type        = number
  default     = 2
}

variable "user_min_count" {
  description = "Minimum number of nodes in user apps pool"
  type        = number
  default     = 1
}

variable "user_max_count" {
  description = "Maximum number of nodes in user apps pool"
  type        = number
  default     = 10
}

variable "user_vm_size" {
  description = "VM size for user apps node pool"
  type        = string
  default     = "Standard_D8s_v3"
}

# VLLM Node Pool Configuration
variable "vllm_node_count" {
  description = "Initial number of nodes in VLLM pool"
  type        = number
  default     = 1
}

variable "vllm_min_count" {
  description = "Minimum number of nodes in VLLM pool"
  type        = number
  default     = 0
}

variable "vllm_max_count" {
  description = "Maximum number of nodes in VLLM pool"
  type        = number
  default     = 5
}

variable "vllm_vm_size" {
  description = "VM size for VLLM node pool (will be updated to GPU later)"
  type        = string
  default     = "Standard_D16s_v3"
}