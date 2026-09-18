output "pages_project_name" {
  description = "Set the PAGES_PROJECT_NAME repository variable to this."
  value       = cloudflare_pages_project.site.name
}

output "pages_dev_address" {
  description = "The address the site is served from before a custom domain exists."
  value       = local.pages_dev_origin
}

output "site_origin" {
  description = "Set the SITE repository variable to this, so canonical URLs, the sitemap and robots.txt are correct."
  value       = local.site_origin
}
