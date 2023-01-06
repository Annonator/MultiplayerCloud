output "adx_endpoint" {
  value = azurerm_kusto_cluster.adx_cluster.uri
  description = "Deployed function app hostname"
}