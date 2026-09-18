output "pages_project_name" {
  description = "Set the PAGES_PROJECT_NAME repository variable to this."
  value       = cloudflare_pages_project.site.name
}

output "pages_dev_address" {
  description = "The address the site is served from before a custom domain exists."
  value       = local.pages_dev_origin
}

output "site_origin" {
  description = "The value the SITE repository variable is expected to hold now: what was passed in, or the pages.dev address."
  value       = local.site_origin
}

output "custom_domain_origin" {
  description = "Set the SITE repository variable to this once custom_domain_status reads active, then redeploy. Empty while site_domain is empty."
  value       = local.custom_origin
}

output "custom_domain_status" {
  description = "Pages status of each custom domain. Wait for active before changing SITE: until then the certificate is not issued."
  value = merge(
    { for d in cloudflare_pages_domain.apex : d.name => d.status },
    { for d in cloudflare_pages_domain.www : d.name => d.status },
  )
}

output "dnssec_ds" {
  description = "The DS record to publish at the registrar. Not needed with Cloudflare Registrar, which publishes it itself. Empty while DNSSEC is off."
  value       = one(cloudflare_zone_dnssec.site[*].ds)
}
