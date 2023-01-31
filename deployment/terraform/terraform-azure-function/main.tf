resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric  = false
}

resource "azurerm_storage_account" "analytics_ingest_storage" {
  name                     = "st${var.environment}analyticssa${random_string.suffix.result}"
  resource_group_name      = var.resourceGroupName
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "analytics_ingest_functionplan" {
  name                = "func-analyticsplan-${var.environment}"
  resource_group_name = var.resourceGroupName
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "analytics_ingest_functionapp" {
  name                = "func-analyticsIngest-${var.environment}"
  resource_group_name = var.resourceGroupName
  location            = var.location

  storage_account_name       = azurerm_storage_account.analytics_ingest_storage.name
  storage_account_access_key = azurerm_storage_account.analytics_ingest_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.analytics_ingest_functionplan.id

  site_config {
    application_insights_connection_string = var.appInsightConnectionString
    application_insights_key = var.appInsightInstrumentationKey
    application_stack {
      dotnet_version = "7.0"
      use_dotnet_isolated_runtime = true
    }
  }
  
  app_settings = {
      analyticsHub = var.eventHubConnectionString 
  }

  connection_string {
    name  = "analyticsHub"
    type  = "EventHub"
    value = var.eventHubConnectionString
  }
}