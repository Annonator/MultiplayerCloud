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

# Setup EventHub
resource "azurerm_resource_group" "eventhub_analyticsIngest" {
  name     = "rg-ehanalyticsingest-${var.environment}"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "analytics" {
  name                = "ns${azurerm_resource_group.eventhub_analyticsIngest.name}"
  location            = azurerm_resource_group.eventhub_analyticsIngest.location
  resource_group_name = azurerm_resource_group.eventhub_analyticsIngest.name
  sku                 = "Basic"
  capacity            = 1
}

resource "azurerm_eventhub" "analytics" {
  name                = "analyticsHub"
  namespace_name      = azurerm_eventhub_namespace.analytics.name
  resource_group_name = azurerm_resource_group.eventhub_analyticsIngest.name
  partition_count     = 1
  message_retention   = 1
}

# Setup Function
resource "azurerm_resource_group" "analytics_ingest_rg" {
  name     = "rg-analytics-ingest-${var.environment}"
  location = var.location
}

module "function"{
  source = "./terraform-azure-function"
  resourceGroupName = azurerm_resource_group.analytics_ingest_rg.name
  location = azurerm_resource_group.analytics_ingest_rg.location
  environment = var.environment
  appInsightConnectionString = azurerm_application_insights.appinsight.connection_string
  appInsightInstrumentationKey = azurerm_application_insights.appinsight.instrumentation_key
  eventHubConnectionString = azurerm_eventhub_namespace.analytics.default_primary_connection_string
}