# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# AKS cluster with enterprise security
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-bain-${var.component}-${var.environment}-${var.region}-${var.sequence}"
  kubernetes_version  = var.kubernetes_version

  # Private cluster configuration
  private_cluster_enabled             = true
  private_dns_zone_id                = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = false

  # Azure AD integration (required for disabling local accounts)
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  # Disable local authentication for policy compliance
  local_account_disabled = true

  # Network configuration
  network_profile {
    network_plugin      = "azure"
    network_policy      = "azure"
    dns_service_ip      = var.dns_service_ip
    service_cidr        = var.service_cidr
    outbound_type      = "userDefinedRouting"
  }

  # Default system node pool
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    vnet_subnet_id               = var.aks_subnet_id
    zones                        = var.availability_zones
    type                         = "VirtualMachineScaleSets"  # Required for zone redundancy
    auto_scaling_enabled         = true
    min_count                    = var.system_min_count
    max_count                    = var.system_max_count
    max_pods                     = 30
    os_disk_size_gb              = 128
    os_disk_type                 = "Managed"
    only_critical_addons_enabled = true
    host_encryption_enabled      = true  # Required by policy for encryption at host

    upgrade_settings {
      max_surge = "33%"
    }
  }

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  # Disk encryption using existing CMK
  disk_encryption_set_id = azurerm_disk_encryption_set.aks.id


  # Auto scaler profile
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                        = "random"
    max_node_provisioning_time      = "15m"
    max_unready_nodes              = 3
    max_unready_percentage         = 45
    new_pod_scale_up_delay         = "10s"
    scale_down_delay_after_add     = "10m"
    scale_down_delay_after_delete  = "10s"
    scale_down_delay_after_failure = "3m"
    scan_interval                  = "10s"
    scale_down_unneeded           = "10m"
    scale_down_unready            = "20m"
    scale_down_utilization_threshold = 0.5
  }

  # Azure Policy add-on
  azure_policy_enabled = true

  # OMS agent for monitoring
  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  # Key Vault secrets provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Workload identity
  workload_identity_enabled = true
  oidc_issuer_enabled      = true

  tags = var.tags
}

# Reference existing Key Vault from security RG
data "azurerm_key_vault" "existing" {
  name                = "kv-bain-dev-incp-uaen-01"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Reference existing managed identity from security RG
data "azurerm_user_assigned_identity" "existing" {
  name                = "id-storage-cmk-dev-incp-uaen-001"
  resource_group_name = "rg-security-dev-incp-uaen-001"
}

# Key for AKS disk encryption in existing Key Vault
resource "azurerm_key_vault_key" "aks_key" {
  name         = "key-aks-${var.component}-${var.environment}-${var.sequence}"
  key_vault_id = data.azurerm_key_vault.existing.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Disk encryption set for AKS
resource "azurerm_disk_encryption_set" "aks" {
  name                      = "des-aks-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  key_vault_key_id          = azurerm_key_vault_key.aks_key.id
  encryption_type           = "EncryptionAtRestWithPlatformAndCustomerKeys"  # Double encryption for policy compliance

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.existing.id]
  }

  tags = var.tags
}


# User apps node pool
resource "azurerm_kubernetes_cluster_node_pool" "user_apps" {
  name                     = "userapps"
  kubernetes_cluster_id    = azurerm_kubernetes_cluster.aks.id
  vm_size                 = var.user_vm_size
  vnet_subnet_id          = var.aks_subnet_id
  zones                   = var.availability_zones
  auto_scaling_enabled    = true
  min_count              = var.user_min_count
  max_count              = var.user_max_count
  max_pods               = 110
  os_disk_size_gb        = 128
  os_disk_type           = "Managed"
  host_encryption_enabled = true  # Required by policy for encryption at host

  # Node labels for workload targeting
  node_labels = {
    "workload-type" = "user-apps"
    "pool-name"     = "userapps"
  }

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags
}

# VLLM workload node pool (normal VMs for now, will be updated to GPU later)
resource "azurerm_kubernetes_cluster_node_pool" "vllm" {
  name                     = "vllm"
  kubernetes_cluster_id    = azurerm_kubernetes_cluster.aks.id
  vm_size                 = var.vllm_vm_size
  vnet_subnet_id          = var.aks_subnet_id
  zones                   = var.availability_zones
  auto_scaling_enabled    = true
  min_count              = var.vllm_min_count
  max_count              = var.vllm_max_count
  max_pods               = 30
  os_disk_size_gb        = 256
  os_disk_type           = "Managed"
  host_encryption_enabled = true  # Required by policy for encryption at host

  # Node labels and taints for ML workloads
  node_labels = {
    "workload-type" = "ml-inference"
    "pool-name"     = "vllm"
    "accelerator"   = "none"  # Will be updated to "gpu" later
  }

  # Taint to ensure only ML workloads are scheduled here
  node_taints = ["workload-type=ml-inference:NoSchedule"]

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags
}

# Private endpoint for AKS
resource "azurerm_private_endpoint" "aks" {
  name                = "pe-${azurerm_kubernetes_cluster.aks.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_kubernetes_cluster.aks.name}"
    private_connection_resource_id = azurerm_kubernetes_cluster.aks.id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }

  tags = var.tags
}