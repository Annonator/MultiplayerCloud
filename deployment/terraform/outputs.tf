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

output "eventhub_connectionString"{
  value = azurerm_eventhub_namespace.analytics.default_primary_connection_string
  description = "Eventhub connectionstring" 
  sensitive = true
}

output "function_app_name" {
  value = module.function.function_app_name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = module.function.function_app_default_hostname
  description = "Deployed function app hostname"
}

output "adx_uri"{
  value = module.adx.adx_endpoint
  description = "ADX Endpoint URL"
}