resource "azurerm_kusto_cluster" "adx_cluster" {
  location            = var.location
  name                = "adxrealtimecluster${var.environment}"
  resource_group_name = var.resourceGroupName

  auto_stop_enabled   = true
  engine              = "V3"

  sku {
    name = var.skuName # This is actually the cheapest supported sku
    capacity = var.capacity
  }
}

resource "azurerm_kusto_database" "adx_ingest_db" {
  cluster_name        = azurerm_kusto_cluster.adx_cluster.name
  location            = azurerm_kusto_cluster.adx_cluster.location
  name                = "realtimeIngest"
  resource_group_name = var.resourceGroupName
}

resource "azurerm_kusto_eventhub_data_connection" "adx_eventhub_connection" {
  cluster_name        = azurerm_kusto_cluster.adx_cluster.name
  consumer_group      = "$Default"
  database_name       = azurerm_kusto_database.adx_ingest_db.name
  eventhub_id         = var.eventHubId
  location            = var.location
  name                = "ingest-adx-eh-connection"
  resource_group_name = var.resourceGroupName

  data_format = "JSON"
  table_name = "realtime-ingest"
}