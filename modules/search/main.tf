# Azure Search Service with enterprise security
resource "azurerm_search_service" "main" {
  name                          = "srch-bain-${var.component}-${var.environment}-incp-${var.region}-${var.sequence}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "standard3"  # Standard3 or higher for zone redundancy
  replica_count                 = 3            # Minimum 3 replicas for zone redundancy
  partition_count               = 1
  public_network_access_enabled = false        # Enterprise policy compliance
  local_authentication_enabled  = false        # Enterprise policy compliance - disable local auth
  
  tags = var.tags
}

# Private endpoint for Azure Search
resource "azurerm_private_endpoint" "search" {
  name                = "pe-${azurerm_search_service.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_search_service.main.name}"
    private_connection_resource_id = azurerm_search_service.main.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  tags = var.tags
}