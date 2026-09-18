variable "cloudflare_api_token" {
  description = "Cloudflare API token with Account > Cloudflare Pages > Edit and, once site_domain is set, Zone > DNS > Edit and Zone > Zone > Read on that one zone. Must not be IP-locked, because CI runners have changing addresses."
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
  description = "Public origin of the production site, no trailing slash. Leave empty to use the pages.dev address until a custom domain exists."
  type        = string
  default     = ""
}

variable "site_domain" {
  description = "The custom domain, bare, for example unifiedpathoflight.com. Its zone must be in this Cloudflare account. Empty means no custom domain: nothing in domain.tf is created. CI passes the SITE_DOMAIN repository variable."
  type        = string
  default     = ""

  validation {
    condition     = var.site_domain == "" || can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.site_domain))
    error_message = "site_domain is a bare lower-case host name, with no scheme, path or trailing dot."
  }
}

variable "enable_dnssec" {
  description = "Turn on DNSSEC for the zone. Complete only once the DS record is at the registrar."
  type        = bool
  default     = false
}

variable "lock_down_email" {
  description = "Publish null MX, SPF -all, DMARC reject and an empty DKIM key, for a domain that never sends or receives email. These records break real mail, including Cloudflare Email Routing."
  type        = bool
  default     = false
}
