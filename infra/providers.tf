# Unified Path of Light: Cloudflare infrastructure as code (OpenTofu).
# Adapted from salvador-cloud-site (MIT), see THIRD-PARTY-NOTICES.md.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.18.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
