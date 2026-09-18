# The custom domain: Pages domains, the DNS records that point at the Pages project, DNSSEC,
# and the records that say the domain sends no email.
#
# Everything here is off while `site_domain` is empty, so the configuration stays a no-op until
# the SITE_DOMAIN repository variable is set. The zone is looked up by name in the same
# account as the Pages project; no zone id is written anywhere.
#
# The API token needs Zone > Zone > Read and Zone > DNS > Edit on this one zone, on top of
# Account > Cloudflare Pages > Edit. See docs/runbook-go-live.md.
#
# www: attached as a second Pages domain, not redirected. Every page carries a canonical URL on
# the apex, so search engines fold the two together, and it needs no redirect ruleset and no
# wider token. A redirect to the apex stays open as a later change.

locals {
  domain_enabled = var.site_domain != ""
  www_enabled    = local.domain_enabled && var.site_domain_www
  dnssec_enabled = local.domain_enabled && var.site_domain_dnssec
  no_email       = local.domain_enabled && var.site_domain_no_email

  www_domain        = "www.${var.site_domain}"
  pages_dev_host    = "${local.project_name}.pages.dev"
  custom_origin     = local.domain_enabled ? "https://${var.site_domain}" : ""
  zone_id           = local.domain_enabled ? data.cloudflare_zone.site[0].zone_id : ""
  managed_by_notice = "Managed by OpenTofu in the upl repository. Do not edit by hand."
}

data "cloudflare_zone" "site" {
  count = local.domain_enabled ? 1 : 0

  filter = {
    name    = var.site_domain
    account = { id = var.cloudflare_account_id }
  }
}

# --- The site ---------------------------------------------------------------------------

resource "cloudflare_pages_domain" "apex" {
  count = local.domain_enabled ? 1 : 0

  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site.name
  name         = var.site_domain
}

resource "cloudflare_pages_domain" "www" {
  count = local.www_enabled ? 1 : 0

  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site.name
  name         = local.www_domain
}

# A CNAME on the apex is allowed because Cloudflare flattens it to addresses when it answers.
resource "cloudflare_dns_record" "apex" {
  count = local.domain_enabled ? 1 : 0

  zone_id = local.zone_id
  name    = var.site_domain
  type    = "CNAME"
  content = local.pages_dev_host
  proxied = true
  ttl     = 1 # automatic, the only value a proxied record accepts
  comment = local.managed_by_notice
}

resource "cloudflare_dns_record" "www" {
  count = local.www_enabled ? 1 : 0

  zone_id = local.zone_id
  name    = local.www_domain
  type    = "CNAME"
  content = local.pages_dev_host
  proxied = true
  ttl     = 1
  comment = local.managed_by_notice
}

# --- DNSSEC -----------------------------------------------------------------------------
#
# Signing the zone is safe on its own. It only takes effect once the DS record (the `dnssec_ds`
# output) is published at the registrar; Cloudflare Registrar does that by itself.
# To turn DNSSEC off, remove the DS record at the registrar FIRST and wait for its TTL to pass,
# or validating resolvers will stop resolving the domain.

resource "cloudflare_zone_dnssec" "site" {
  count = local.dnssec_enabled ? 1 : 0

  zone_id = local.zone_id
  status  = "active"
}

# --- A domain that sends no email -------------------------------------------------------
#
# Without these, anyone can send mail that claims to come from the domain. Together they tell
# receivers: no server accepts mail here (null MX, RFC 7505), no server may send it (SPF), no
# key signs it (empty DKIM), and anything claiming otherwise is to be rejected (DMARC).
# TXT content is wrapped in quotes because that is how the Cloudflare API stores it; without
# them every plan shows a change.

resource "cloudflare_dns_record" "null_mx" {
  count = local.no_email ? 1 : 0

  zone_id  = local.zone_id
  name     = var.site_domain
  type     = "MX"
  content  = "."
  priority = 0
  ttl      = 1
  comment  = local.managed_by_notice
}

resource "cloudflare_dns_record" "spf" {
  count = local.no_email ? 1 : 0

  zone_id = local.zone_id
  name    = var.site_domain
  type    = "TXT"
  content = "\"v=spf1 -all\""
  ttl     = 1
  comment = local.managed_by_notice
}

resource "cloudflare_dns_record" "dkim" {
  count = local.no_email ? 1 : 0

  zone_id = local.zone_id
  name    = "*._domainkey.${var.site_domain}"
  type    = "TXT"
  content = "\"v=DKIM1; p=\""
  ttl     = 1
  comment = local.managed_by_notice
}

resource "cloudflare_dns_record" "dmarc" {
  count = local.no_email ? 1 : 0

  zone_id = local.zone_id
  name    = "_dmarc.${var.site_domain}"
  type    = "TXT"
  content = "\"v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s\""
  ttl     = 1
  comment = local.managed_by_notice
}
