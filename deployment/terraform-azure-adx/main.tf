resource "random_string" "suffix" {
  length  = 2
  special = false
  upper   = false
  numeric  = false
}

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

# Now we create the script to create a table and mapping in a storage account
resource "azurerm_storage_account" "script_storage_account" {
  name                     = "st${var.environment}adxscript${random_string.suffix.result}"
  resource_group_name      = var.resourceGroupName
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "script_storage_container" {
  name                  = "setupfiles"
  storage_account_name  = azurerm_storage_account.script_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "script_blob" {
  name                    = "script.kql"
  storage_account_name    = azurerm_storage_account.script_storage_account.name
  storage_container_name  = azurerm_storage_container.script_storage_container.name
  type                    = "Block"
  source                  = "./terraform-azure-adx/script.kql"
}

data "azurerm_storage_account_blob_container_sas" "blob_sas"{
  connection_string = azurerm_storage_account.script_storage_account.primary_connection_string
  container_name    = azurerm_storage_container.script_storage_container.name
  https_only        = true

  start  = "2023-01-01"
  expiry = "2023-03-21"

  permissions {
    read   = true
    add    = false
    create = false
    write  = true
    delete = false
    list   = true
  }
}

resource "azurerm_kusto_script" "script" {
  database_id = azurerm_kusto_database.adx_ingest_db.id
  name        = "createTableAndMapScript"
  sas_token   = data.azurerm_storage_account_blob_container_sas.blob_sas.sas
  url         = azurerm_storage_blob.script_blob.id
  continue_on_errors_enabled = false
}

resource "azurerm_kusto_eventhub_data_connection" "adx_eventhub_connection" {
  depends_on          = [azurerm_kusto_script.script]
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