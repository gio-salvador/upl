# The Cloudflare Pages project.
#
# DIRECT-UPLOAD project: no `source` block. The build and the upload happen in GitHub Actions
# (.github/workflows/deploy.yml), so the link and SEO gates run before anything is published.
# A git-connected project would build on Cloudflare's side and conflict with that workflow.
#
# The site is plain static files. No Functions, no bindings, no environment secrets.

locals {
  # The deploy workflow uses the same fallback, so the two always name the same project.
  project_name     = var.pages_project_name != "" ? var.pages_project_name : "unified-path-of-light"
  pages_dev_origin = "https://${local.project_name}.pages.dev"
  site_origin      = var.site_origin != "" ? var.site_origin : local.pages_dev_origin
}

resource "cloudflare_pages_project" "site" {
  account_id        = var.cloudflare_account_id
  name              = local.project_name
  production_branch = var.pages_production_branch
}
