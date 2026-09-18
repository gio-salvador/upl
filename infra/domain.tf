# The custom domain: unifiedpathoflight.com, whose nameservers point to Cloudflare, so the
# zone is in the same account as the Pages project.
#
# Everything here is off until `site_domain` is set (CI passes the SITE_DOMAIN repository
# variable, empty until then), so a plan with no domain is unchanged. The order of going live
# is in docs/runbook-go-live.md: attach the domain, wait for the certificate, then move SITE.
#
# The apex and www are both attached to the Pages project. Every page carries a canonical URL
# on the SITE origin, so www is a convenience for people who type it, not a second site.

locals {
  domain_enabled = var.site_domain != ""
  site_hosts     = local.domain_enabled ? toset([var.site_domain, "www.${var.site_domain}"]) : toset([])
  zone_id        = local.domain_enabled ? data.cloudflare_zone.site[0].zone_id : ""
  pages_target   = "${local.project_name}.pages.dev"
}

data "cloudflare_zone" "site" {
  count = local.domain_enabled ? 1 : 0
  filter = {
    name = var.site_domain
  }
}

resource "cloudflare_pages_domain" "site" {
  for_each     = local.site_hosts
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site.name
  name         = each.value
}

# Proxied CNAMEs to the pages.dev address. Cloudflare flattens the CNAME at the apex.
resource "cloudflare_dns_record" "site" {
  for_each = local.site_hosts
  zone_id  = local.zone_id
  name     = each.value
  type     = "CNAME"
  content  = local.pages_target
  proxied  = true
  ttl      = 1
  comment  = "Unified Path of Light site (managed by OpenTofu)"

  depends_on = [cloudflare_pages_domain.site]
}

# DNSSEC. Off by default because it is only complete once the DS record is at the registrar
# (automatic when the registrar is Cloudflare; otherwise copy it from the dashboard).
resource "cloudflare_zone_dnssec" "site" {
  count   = local.domain_enabled && var.enable_dnssec ? 1 : 0
  zone_id = local.zone_id
  status  = "active"
}

# A domain that sends no email should say so, or anyone can forge mail from it: a null MX, an
# SPF record that authorises nobody, and a DMARC policy of reject. Off by default, because
# these records would break real mail. Turn it on only if the domain will never send or
# receive email (Cloudflare Email Routing counts as email).
locals {
  no_email_txt = local.domain_enabled && var.lock_down_email ? {
    spf   = { name = var.site_domain, content = "\"v=spf1 -all\"" }
    dmarc = { name = "_dmarc.${var.site_domain}", content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s\"" }
    dkim  = { name = "*._domainkey.${var.site_domain}", content = "\"v=DKIM1; p=\"" }
  } : {}
}

resource "cloudflare_dns_record" "no_email_txt" {
  for_each = local.no_email_txt
  zone_id  = local.zone_id
  name     = each.value.name
  type     = "TXT"
  content  = each.value.content
  ttl      = 1
  comment  = "This domain sends no email (managed by OpenTofu)"
}

resource "cloudflare_dns_record" "null_mx" {
  count    = local.domain_enabled && var.lock_down_email ? 1 : 0
  zone_id  = local.zone_id
  name     = var.site_domain
  type     = "MX"
  content  = "."
  priority = 0
  ttl      = 1
  comment  = "Null MX, RFC 7505: this domain receives no email (managed by OpenTofu)"
}
