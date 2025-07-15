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