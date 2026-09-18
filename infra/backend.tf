# State lives in a Cloudflare R2 bucket through the S3-compatible API. The bucket name and
# endpoint are passed at init time, never committed:
#
#   tofu init \
#     -backend-config="bucket=<state bucket>" \
#     -backend-config="endpoints={s3=\"https://<account id>.r2.cloudflarestorage.com\"}"
#
# with the R2 access key pair in AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

terraform {
  backend "s3" {
    region                      = "auto"
    key                         = "upl/terraform.tfstate"
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
