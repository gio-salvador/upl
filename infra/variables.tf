variable "cloudflare_api_token" {
  description = "Cloudflare API token with Account > Cloudflare Pages > Edit. Once site_domain is set it also needs Zone > Zone > Read and Zone > DNS > Edit, limited to that one zone. Must not be IP-locked, because CI runners have changing addresses."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "The Cloudflare account that owns the Pages project. Marked sensitive so it is masked in plan output, which the IaC workflow posts as a pull request comment."
  type        = string
  sensitive   = true
}

variable "pages_project_name" {
  description = "Name of the Pages project. Also the pages.dev subdomain, so it must be globally unique. Empty means the default in pages.tf; CI passes the PAGES_PROJECT_NAME repository variable, which is empty until it is set."
  type        = string
  default     = ""
}

variable "pages_production_branch" {
  description = "The branch whose deployments are production."
  type        = string
  default     = "main"
}

variable "site_origin" {
  description = "Public origin of the production site, no trailing slash. Leave empty to use the pages.dev address. Set it to the custom_domain_origin output only after the custom domain is active; CI passes the SITE repository variable."
  type        = string
  default     = ""
}

variable "site_domain" {
  description = "Apex custom domain, for example unifiedpathoflight.com: no scheme, no www, no trailing dot. Its zone must be in the same Cloudflare account. Empty means no custom domain and no DNS records; CI passes the SITE_DOMAIN repository variable, which is empty until it is set."
  type        = string
  default     = ""

  validation {
    condition     = var.site_domain == "" || can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.site_domain))
    error_message = "site_domain must be a bare lower-case domain name such as unifiedpathoflight.com, or empty."
  }

  validation {
    condition     = !startswith(var.site_domain, "www.")
    error_message = "site_domain is the apex. The www name is added by site_domain_www."
  }
}

variable "site_domain_www" {
  description = "Also serve the site on www.<site_domain>, as a second Pages domain. No effect while site_domain is empty."
  type        = bool
  default     = true
}

variable "site_domain_dnssec" {
  description = "Sign the zone with DNSSEC. The DS record in the dnssec_ds output must then be published at the registrar, unless the registrar is Cloudflare. No effect while site_domain is empty."
  type        = bool
  default     = true
}

variable "site_domain_no_email" {
  description = "Publish the records that say the domain sends and receives no email: null MX, SPF -all, an empty wildcard DKIM key and DMARC reject. Set to false before the domain is ever used for email. No effect while site_domain is empty."
  type        = bool
  default     = true
}
