variable "cloudflare_api_token" {
  description = "Cloudflare API token with Account > Cloudflare Pages > Edit. Must not be IP-locked, because CI runners have changing addresses."
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
