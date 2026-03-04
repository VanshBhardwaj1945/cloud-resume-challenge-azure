# Cloudflare DNS - TXT record for AFD custom domain validation
resource "cloudflare_dns_record" "dnsauth" {
  zone_id = var.cloudflare_zone_id
  name    = "_dnsauth.resume"
  type    = "TXT"
  ttl     = 1
  content = azurerm_cdn_frontdoor_custom_domain.custom.validation_token

  lifecycle {
    ignore_changes = [content]
  }
}

# Cloudflare DNS - CNAME pointing resume subdomain to Front Door endpoint
resource "cloudflare_dns_record" "resume_cname" {
  depends_on = [
    azurerm_cdn_frontdoor_route.resume-route,
    azurerm_cdn_frontdoor_custom_domain.custom,
  ]

  zone_id = var.cloudflare_zone_id
  name    = "resume"
  type    = "CNAME"
  ttl     = 1
  content = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
  proxied = true
  comment = "Resume Sub Domain - Connected to Azure front door endpoint - For CRC Challenge"
}

# DNSSEC for vanshbhardwaj.com zone
resource "cloudflare_zone_dnssec" "vanshbhardwaj_dnssec" {
  zone_id = var.cloudflare_zone_id

  lifecycle {
    ignore_changes = [
      algorithm, digest, digest_algorithm, digest_type,
      ds, flags, key_tag, key_type, modified_on, public_key, status
    ]
  }
}
