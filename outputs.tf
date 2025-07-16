output "storage_accounts" {
  description = "Map of all created storage accounts with their details"
  value = {
    for purpose, account in module.storage_accounts : purpose => {
      name = account.storage_account_name
      id   = account.storage_account_id
      primary_blob_endpoint = account.storage_account_primary_endpoint
    }
  }
}

output "storage_account_names" {
  description = "Names of all created storage accounts"
  value = {
    for purpose, account in module.storage_accounts : purpose => account.storage_account_name
  }
}

output "key_vault_uri" {
  description = "URI of the Key Vault used for CMK"
  value       = values(module.storage_accounts)[0].key_vault_uri
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = values(module.storage_accounts)[0].resource_group_name
}

# PostgreSQL outputs
output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.postgresql.postgresql_server_name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.postgresql.postgresql_server_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database"
  value       = module.postgresql.database_name
}

output "postgresql_admin_password" {
  description = "Generated PostgreSQL admin password"
  value       = module.postgresql.admin_password
  sensitive   = true
}

# Azure Search outputs
output "search_service_name" {
  description = "Name of the Azure Search service"
  value       = module.search.search_service_name
}

output "search_service_url" {
  description = "URL of the Azure Search service"
  value       = module.search.search_service_url
}

# Redis outputs
output "redis_cache_name" {
  description = "Name of the Redis cache"
  value       = module.redis.redis_cache_name
}

output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = module.redis.redis_hostname
}

output "redis_primary_access_key" {
  description = "Primary access key for Redis"
  value       = module.redis.redis_primary_access_key
  sensitive   = true
}

# Key Vault outputs
output "key_vaults" {
  description = "Map of all created Key Vaults with their details"
  value = {
    for purpose, vault in module.key_vaults : purpose => {
      id          = vault.key_vault_id
      name        = vault.key_vault_name
      uri         = vault.key_vault_uri
      private_ip  = vault.private_endpoint_ip
      application_key_id = vault.application_key_id
    }
  }
}

output "key_vault_names" {
  description = "Names of all created Key Vaults"
  value = {
    for purpose, vault in module.key_vaults : purpose => vault.key_vault_name
  }
}

output "key_vault_uris" {
  description = "URIs of all created Key Vaults"
  value = {
    for purpose, vault in module.key_vaults : purpose => vault.key_vault_uri
  }
}

# AKS outputs - COMMENTED OUT (module disabled due to firewall configuration issue)
# output "aks_cluster_name" {
#   description = "Name of the AKS cluster"
#   value       = module.aks.aks_cluster_name
# }

# output "aks_cluster_fqdn" {
#   description = "FQDN of the AKS cluster"
#   value       = module.aks.aks_cluster_fqdn
# }

# output "aks_cluster_private_fqdn" {
#   description = "Private FQDN of the AKS cluster"
#   value       = module.aks.aks_cluster_private_fqdn
# }

# output "aks_kube_config" {
#   description = "Kubernetes configuration for the AKS cluster"
#   value       = module.aks.aks_kube_config
#   sensitive   = true
# }

# output "aks_oidc_issuer_url" {
#   description = "OIDC issuer URL for workload identity"
#   value       = module.aks.aks_oidc_issuer_url
# }

# output "system_node_pool_name" {
#   description = "Name of the system node pool"
#   value       = module.aks.system_node_pool_name
# }

# output "user_apps_node_pool_name" {
#   description = "Name of the user apps node pool"
#   value       = module.aks.user_apps_node_pool_name
# }

# output "vllm_node_pool_name" {
#   description = "Name of the VLLM node pool"
#   value       = module.aks.vllm_node_pool_name
# }

# Azure OpenAI outputs - COMMENTED OUT (NSP restrictions still in place)
# output "openai_account_name" {
#   description = "Name of the Azure OpenAI account"
#   value       = module.openai.openai_account_name
# }

# output "openai_endpoint" {
#   description = "Endpoint URL for Azure OpenAI"
#   value       = module.openai.openai_endpoint
# }

# output "openai_primary_access_key" {
#   description = "Primary access key for Azure OpenAI"
#   value       = module.openai.openai_primary_access_key
#   sensitive   = true
# }

# output "gpt41_deployment_name" {
#   description = "Name of the GPT-4.1 deployment"
#   value       = module.openai.gpt41_deployment_name
# }

# output "embedding_deployment_name" {
#   description = "Name of the text embedding deployment"
#   value       = module.openai.embedding_deployment_name
# }