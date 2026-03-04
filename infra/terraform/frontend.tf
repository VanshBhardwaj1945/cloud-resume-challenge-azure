# Frontend - Static website storage account
resource "azurerm_storage_account" "crcfrontendra" {
  name                = "crcfrontendra"
  resource_group_name = azurerm_resource_group.crc-frontend-rg.name
  location            = azurerm_resource_group.crc-frontend-rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

  lifecycle {
    ignore_changes = [allow_nested_items_to_be_public]
  }
}

# Front Door profile
resource "azurerm_cdn_frontdoor_profile" "crc-resume-fd" {
  name                     = "crc-resume-fd"
  resource_group_name      = azurerm_resource_group.crc-frontend-rg.name
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
}

# Origin group
resource "azurerm_cdn_frontdoor_origin_group" "resume-origin-group" {
  name                     = "resume-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.crc-resume-fd.id

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false

  health_probe {
    protocol            = "Https"
    interval_in_seconds = 100
    request_type        = "HEAD"
    path                = "/"
  }

  load_balancing {}
}

# Origin - points to the static website storage endpoint
resource "azurerm_cdn_frontdoor_origin" "example" {
  name                           = "crcfrontendra-staticwebsite"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.resume-origin-group.id
  enabled                        = true
  certificate_name_check_enabled = true

  host_name          = "crcfrontendra.z19.web.core.windows.net"
  origin_host_header = "crcfrontendra.z19.web.core.windows.net"

  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 1000
}

# Front Door endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "crc-vansh-resume"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.crc-resume-fd.id
  tags                     = {}
}

# Route - maps endpoint to origin group with caching and custom domain
resource "azurerm_cdn_frontdoor_route" "resume-route" {
  name                          = "frontendra-fd-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.resume-origin-group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.example.id]

  supported_protocols    = ["Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = false

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.custom.id]

  lifecycle {
    ignore_changes = [cdn_frontdoor_origin_ids]
  }

  cache {
    compression_enabled           = true
    query_string_caching_behavior = "IgnoreQueryString"
    content_types_to_compress = [
      "application/eot", "application/font", "application/font-sfnt",
      "application/javascript", "application/json", "application/opentype",
      "application/otf", "application/pkcs7-mime", "application/truetype",
      "application/ttf", "application/vnd.ms-fontobject", "application/xhtml+xml",
      "application/xml", "application/xml+rss", "application/x-font-opentype",
      "application/x-font-truetype", "application/x-font-ttf", "application/x-httpd-cgi",
      "application/x-javascript", "application/x-mpegurl", "application/x-opentype",
      "application/x-otf", "application/x-perl", "application/x-ttf",
      "font/eot", "font/ttf", "font/otf", "font/opentype", "image/svg+xml",
      "text/css", "text/csv", "text/html", "text/javascript", "text/js",
      "text/plain", "text/richtext", "text/tab-separated-values", "text/xml",
      "text/x-script", "text/x-component", "text/x-java-source"
    ]
  }
}

# Custom domain with managed TLS certificate
resource "azurerm_cdn_frontdoor_custom_domain" "custom" {
  name                     = "resume-vanshbhardwaj-com-4f0a"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.crc-resume-fd.id
  host_name                = "resume.vanshbhardwaj.com"

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}
