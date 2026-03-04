# CosmosDB account - serverless, used for visitor counter
resource "azurerm_cosmosdb_account" "crc-visitor-counter" {
  name                = "crc-visitor-counter"
  resource_group_name = azurerm_resource_group.crc-backend-rg.name
  location            = "West US 2"

  offer_type                 = "Standard"
  kind                       = "GlobalDocumentDB"
  automatic_failover_enabled = true

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = "West US 2"
    failover_priority = 0
  }

  public_network_access_enabled = true

  tags = {
    defaultExperience    = "Core (SQL)"
    hidden-workload-type = "Learning"
  }

  lifecycle {
    ignore_changes = [tags["hidden-cosmos-mmspecial"]]
  }
}

# CosmosDB SQL database
resource "azurerm_cosmosdb_sql_database" "counter_db" {
  name                = "counter"
  resource_group_name = azurerm_resource_group.crc-backend-rg.name
  account_name        = azurerm_cosmosdb_account.crc-visitor-counter.name
}

# CosmosDB container - stores visitor count document
resource "azurerm_cosmosdb_sql_container" "visitor_container" {
  name                  = "visitorcount"
  resource_group_name   = azurerm_resource_group.crc-backend-rg.name
  account_name          = azurerm_cosmosdb_account.crc-visitor-counter.name
  database_name         = azurerm_cosmosdb_sql_database.counter_db.name
  partition_key_paths   = ["/id"]
  partition_key_version = 2
}

# Storage account for Function App deployment packages
resource "azurerm_storage_account" "crcbackendrg9af7" {
  name                            = "crcbackendrg9af7"
  resource_group_name             = azurerm_resource_group.crc-backend-rg.name
  location                        = "eastus"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true

  lifecycle {
    ignore_changes = [tags]
  }
}

# Blob container for Function App deployment packages
resource "azurerm_storage_container" "deployment_container" {
  name                  = "app-package-page-counter-52f547a"
  storage_account_id    = azurerm_storage_account.crcbackendrg9af7.id
  container_access_type = "private"

}

# App Service Plan - Flex Consumption (serverless)
resource "azurerm_service_plan" "crc-backend-asp" {
  name                = "ASP-crcbackendrg-9747"
  resource_group_name = azurerm_resource_group.crc-backend-rg.name
  location            = "eastus"
  os_type             = "Linux"
  sku_name            = "FC1"

  lifecycle {
    ignore_changes = [tags]
  }
}

# Function App - Python 3.11, Flex Consumption, visitor counter API
resource "azurerm_function_app_flex_consumption" "page-counter" {
  name                = "page-counter"
  resource_group_name = azurerm_resource_group.crc-backend-rg.name
  location            = "eastus"
  service_plan_id     = azurerm_service_plan.crc-backend-asp.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.crcbackendrg9af7.primary_blob_endpoint}${azurerm_storage_container.deployment_container.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.crcbackendrg9af7.primary_access_key

  runtime_name    = "python"
  runtime_version = "3.11"

  maximum_instance_count                         = 100
  instance_memory_in_mb                          = 2048
  https_only                                     = true
  client_certificate_mode                        = "Required"
  webdeploy_publish_basic_authentication_enabled = false

  app_settings = {
    COSMOSDB_CONNECTION_STRING = var.cosmosdb_connection_string
  }

  site_config {
    ip_restriction_default_action          = "Allow"
    scm_ip_restriction_default_action      = "Allow"
    application_insights_connection_string = var.app_insights_connection_string
    cors {
      allowed_origins = [
        "https://crcfrontendra.z19.web.core.windows.net",
        "https://resume.vanshbhardwaj.com",
      ]
      support_credentials = true
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
