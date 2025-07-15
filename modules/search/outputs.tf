output "search_service_id" {
  description = "ID of the Azure Search service"
  value       = azurerm_search_service.main.id
}

output "search_service_name" {
  description = "Name of the Azure Search service"
  value       = azurerm_search_service.main.name
}

output "search_service_url" {
  description = "URL of the Azure Search service"
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}

output "private_endpoint_id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.search.id
}