# Cloudflare zone ID for vanshbhardwaj.com
variable "cloudflare_zone_id" {
  type = string
}

# CosmosDB connection string for the Function App
variable "cosmosdb_connection_string" {
  type      = string
  sensitive = true
}

# Application Insights connection string for the Function App
variable "app_insights_connection_string" {
  type      = string
  sensitive = true
}
