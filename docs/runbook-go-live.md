# Runbook: go live on Cloudflare Pages

The one-time steps that connect this repository to Cloudflare, for the repository owner. Until
they are done, the deploy workflow builds and checks the site but uploads nothing, and the IaC
workflow only formats and validates. Every credential here is created and entered by you; none
is ever written to a file in this repository.

## What you need

- A Cloudflare account (the free plan is enough) and its account id.
- OpenTofu 1.10 or later on your machine for the first apply.

## 1. Create the state bucket

In the Cloudflare dashboard, under R2, create a bucket for OpenTofu state, then create an R2 API
token with read and write access to that bucket only. Note the access key id, the secret access
key, and the S3 endpoint (`https://<account id>.r2.cloudflarestorage.com`).

## 2. Create the API token

Create a Cloudflare API token with one permission: Account, Cloudflare Pages, Edit, limited to
the one account. Do not add an IP restriction: GitHub's runners have changing addresses, and an
IP-locked token fails from CI.

## 3. Create the Pages project with the first apply

```bash
cd infra
export AWS_ACCESS_KEY_ID=...            # the R2 access key id
export AWS_SECRET_ACCESS_KEY=...        # the R2 secret access key
export TF_VAR_cloudflare_api_token=...  # the API token from step 2
export TF_VAR_cloudflare_account_id=... # your account id
tofu init \
  -backend-config="bucket=<state bucket>" \
  -backend-config='endpoints={s3="https://<account id>.r2.cloudflarestorage.com"}'
tofu plan
tofu apply
```

The plan should show one resource to add, the Pages project. If the default project name is
already taken on pages.dev, set `TF_VAR_pages_project_name` to another name and use the same
value for the `PAGES_PROJECT_NAME` variable below. The outputs print the values for step 4.

## 4. Give GitHub the secrets and variables

Secrets (Settings, Secrets and variables, Actions, Secrets):

| Secret | Value |
| ------ | ----- |
| `CLOUDFLARE_API_TOKEN` | the API token from step 2 |
| `CLOUDFLARE_ACCOUNT_ID` | your account id |
| `TOFU_STATE_ACCESS_KEY_ID` | the R2 access key id |
| `TOFU_STATE_SECRET_ACCESS_KEY` | the R2 secret access key |
| `TOFU_STATE_BUCKET` | the state bucket name |
| `TOFU_STATE_ENDPOINT` | the R2 S3 endpoint |

Variables (same page, Variables tab):

| Variable | Value |
| -------- | ----- |
| `PAGES_PROJECT_NAME` | the `pages_project_name` output |
| `SITE` | the `site_origin` output, for example the pages.dev address |
| `IAC_ENABLED` | `true` |

`gh secret set <NAME>` prompts for each value without echoing it, which keeps secrets out of
your shell history.

Optional but recommended: a `SENSITIVE_TOKENS` secret holding your sensitive-token list, one
token per line. CI then scans every tracked file against it on every pull request. The list
itself never enters the repository.

## 5. Deploy

Run the Deploy workflow from the Actions tab, or merge any pull request. The run uploads the
site and then smoke-tests the live address: security headers, sitemap, robots, the llms files,
a deep page, its markdown alternate, and the redirect for a page address without its slash.

## 6. Protect `main`

Once the repository is public (or on a paid GitHub plan), add a branch ruleset on `main`: pull
request required, the three CI checks and the Deploy check required, signed commits, no force
push, no deletion. On a private repository on the free plan GitHub refuses this; that is a
recorded gap, not a pass.

## 7. Repository settings

These are account settings, so they are yours to apply:

```bash
gh api -X PUT repos/gio-salvador/upl/vulnerability-alerts
gh api -X PUT repos/gio-salvador/upl/automated-security-fixes
gh api -X PATCH repos/gio-salvador/upl -F delete_branch_on_merge=true
```

The first two turn on Dependabot alerts and security updates, which the free plan offers on a
private repository. Once the repository is public, also turn on secret scanning and push
protection in Settings, Code security.

## 8. Attach the custom domain

The domain is unifiedpathoflight.com. Its nameservers already point to Cloudflare, so its zone
must be in the same account as the Pages project. Do this after step 5 has deployed once.

1. Widen the API token from step 2 (or create a new one and replace the secret) with two more
   permissions, limited to the unifiedpathoflight.com zone: Zone, DNS, Edit and Zone, Zone,
   Read. Still no IP restriction.
2. In the Cloudflare dashboard, check the zone's DNS records. If the apex or `www` already has
   an A, AAAA or CNAME record (a parking page, for example), delete it, or the apply fails on
   the conflict.
3. Set the repository variable `SITE_DOMAIN` to `unifiedpathoflight.com`, then run the IaC
   workflow (or merge a pull request that touches `infra/`). The plan should add four
   resources: a Pages domain and a CNAME record for the apex and for `www`.
4. Wait for the certificates. The `custom_domain_status` output shows each host; both should
   read `active`, usually within a few minutes. `https://unifiedpathoflight.com/` then answers
   with the site.
5. Only now set the repository variable `SITE` to `https://unifiedpathoflight.com` (no trailing
   slash) and run the Deploy workflow. Canonical URLs, the sitemap, `robots.txt`, the llms
   files and the smoke test all move to the new origin in that one deploy. Moving `SITE`
   before the certificate is active would make the smoke test fail and publish canonical URLs
   that do not answer yet.

Two optional switches, each a repository variable set to `true`:

| Variable | What it does | Turn it on when |
| -------- | ------------ | --------------- |
| `ENABLE_DNSSEC` | Signs the zone | Always worth it. With Cloudflare as the registrar the DS record is added for you; with another registrar, copy the DS record from the dashboard's DNS settings to the registrar, or it stays pending. |
| `LOCK_DOWN_EMAIL` | Publishes a null MX, SPF `-all`, DMARC `reject` and an empty DKIM key, so nobody can forge mail from the domain | Only if the domain will never send or receive email. These records break real mail, including Cloudflare Email Routing. |

The HSTS header in `site/public/_headers` deliberately leaves out `includeSubDomains` and
`preload`. Add them only when every subdomain of unifiedpathoflight.com, present and planned,
is HTTPS-only: preload is slow to undo. That is a separate, reviewed change to `_headers`.

## Rolling back

A bad deployment: in the Cloudflare dashboard, Pages, the project, Deployments, choose the last
good one and roll back to it; then revert the pull request. Removing everything: `tofu destroy`
in `infra/`, then revoke the API token and the R2 token. To detach only the custom domain, set `SITE`
back to the pages.dev address and deploy, then clear `SITE_DOMAIN` and apply.
