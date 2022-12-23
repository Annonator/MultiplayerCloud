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

resource "azurerm_resource_group" "analytics_ingest_rg" {
  name     = "rg-prod-analytics-ingest"
  location = "West Europe"
}

resource "azurerm_storage_account" "analytics_ingest_storage" {
  name                     = "linuxfunctionappsa"
  resource_group_name      = azurerm_resource_group.analytics_ingest_rg.name
  location                 = azurerm_resource_group.analytics_ingest_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "analytics_ingest_functionplan" {
  name                = "example-app-service-plan"
  resource_group_name = azurerm_resource_group.analytics_ingest_rg.name
  location            = azurerm_resource_group.analytics_ingest_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "analytics_ingest_functionapp" {
  name                = "example-linux-function-app"
  resource_group_name = azurerm_resource_group.analytics_ingest_rg.name
  location            = azurerm_resource_group.analytics_ingest_rg.location

  storage_account_name       = azurerm_storage_account.analytics_ingest_storage.name
  storage_account_access_key = azurerm_storage_account.analytics_ingest_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.analytics_ingest_functionplan.id

  site_config {}
}