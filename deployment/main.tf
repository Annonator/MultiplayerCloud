# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.37.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Set up application insights
resource "azurerm_resource_group" "appinsight_rg" {
  name     = "rg-appinsight-${var.environment}"
  location = "West Europe"
}

resource "azurerm_application_insights" "appinsight" {
  name                = "ai-insight-${var.environment}"
  location            = azurerm_resource_group.appinsight_rg.location
  resource_group_name = azurerm_resource_group.appinsight_rg.name
  application_type    = "web"
}

# Setup Function
resource "azurerm_resource_group" "analytics_ingest_rg" {
  name     = "rg-analytics-ingest-${var.environment}"
  location = var.location
}

resource "azurerm_storage_account" "analytics_ingest_storage" {
  name                     = "st${var.environment}analyticssa"
  resource_group_name      = azurerm_resource_group.analytics_ingest_rg.name
  location                 = azurerm_resource_group.analytics_ingest_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "analytics_ingest_functionplan" {
  name                = "func-analyticsplan-${var.environment}"
  resource_group_name = azurerm_resource_group.analytics_ingest_rg.name
  location            = azurerm_resource_group.analytics_ingest_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "analytics_ingest_functionapp" {
  name                = "func-analyticsIngest-${var.environment}"
  resource_group_name = azurerm_resource_group.analytics_ingest_rg.name
  location            = azurerm_resource_group.analytics_ingest_rg.location

  storage_account_name       = azurerm_storage_account.analytics_ingest_storage.name
  storage_account_access_key = azurerm_storage_account.analytics_ingest_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.analytics_ingest_functionplan.id

  site_config {
    application_insights_connection_string = azurerm_application_insights.appinsight.connection_string
    application_insights_key = azurerm_application_insights.appinsight.instrumentation_key
    application_stack {
      dotnet_version = "7.0"
      use_dotnet_isolated_runtime = true
    }
  }
}