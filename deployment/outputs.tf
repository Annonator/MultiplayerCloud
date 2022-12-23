output "instrumentation_key" {
  value = azurerm_application_insights.appinsight.instrumentation_key
  sensitive = true
}

output "appinsight_connectionString"{
  value = azurerm_application_insights.appinsight.connection_string
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.appinsight.app_id
}
output "function_app_name" {
  value = azurerm_linux_function_app.analytics_ingest_functionapp.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.analytics_ingest_functionapp.default_hostname
  description = "Deployed function app hostname"
}

output "eventhub_connectionString"{
  value = azurerm_eventhub_namespace.analytics.default_primary_connection_string
  description = "Eventhub connectionstring" 
  sensitive = true
}