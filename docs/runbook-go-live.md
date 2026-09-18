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

That is enough until the custom domain is attached. Step 8 widens the same token with two zone
permissions; if you already know you will attach the domain straight away, add them now.

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
| `SITE` | the `site_origin` output, the pages.dev address; step 8 changes it to the custom domain |
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
request required, the four CI checks (site gate, rendering gate, toolkit gates, gitleaks) and
the Deploy check required, signed commits, no force
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

The production domain is unifiedpathoflight.com. Its nameservers already point at Cloudflare,
so the zone sits in the same account as the Pages project. `infra/domain.tf` does nothing until
it is given the domain name. The order below matters: the site must not announce the new
address in its canonical URLs and sitemap before that address serves a valid certificate.

1. **Widen the API token.** Edit the token from step 2 and add two permissions, both limited to
   the one zone (Zone Resources, Include, Specific zone, unifiedpathoflight.com):

   | Permission | Why |
   | ---------- | --- |
   | Zone, Zone, Read | OpenTofu looks the zone up by name, so no zone id is written anywhere |
   | Zone, DNS, Edit | the DNS records and DNSSEC |

   Account, Cloudflare Pages, Edit stays as it is. Editing a token keeps its value, so the
   `CLOUDFLARE_API_TOKEN` secret does not change.
2. **Clear the way in the zone.** In the dashboard, under DNS, Records, delete any record that
   a registrar import left behind on the names the apply is about to create: the apex (A, AAAA
   or CNAME, any MX, and an SPF TXT record), `www`, `_dmarc` and `*._domainkey`. OpenTofu
   refuses to overwrite a record it did not create, and the apply fails with a conflict. Under
   DNS, Settings, check also that DNSSEC is not already on or half set up from elsewhere; if a
   stale DS record sits at the registrar, remove it before the apply.
3. **Give OpenTofu the domain.** Set the repository variable `SITE_DOMAIN` to
   `unifiedpathoflight.com`. Leave `SITE` alone for now.
4. **Apply.** Run the IaC workflow from the Actions tab on `main`, or run `tofu apply` locally
   as in step 3 with `TF_VAR_site_domain` set as well. The plan adds nine resources: two Pages
   domains (the apex and `www`), two proxied CNAME records pointing at the pages.dev address,
   DNSSEC, and four records saying the domain sends no email (null MX, SPF `-all`, an empty
   wildcard DKIM key, DMARC `p=reject`).
5. **Publish the DS record**, unless the domain is registered with Cloudflare Registrar, which
   does it for you. `tofu output dnssec_ds` prints the record; add it at the registrar.
6. **Wait for the certificate.** `tofu apply -refresh-only` then `tofu output
   custom_domain_status` shows each domain; wait for both to read `active`. It usually takes a
   few minutes. Then confirm by hand:

   ```bash
   curl -sI https://unifiedpathoflight.com/ | head -n 1
   ```

   A `200` over HTTPS with no certificate warning means the address is ready. Check too that
   `curl -sI http://unifiedpathoflight.com/` answers with a redirect to HTTPS; if it does not,
   turn on Always Use HTTPS in the dashboard under SSL/TLS, Edge Certificates. That setting is
   not in OpenTofu because it would need a token that can edit zone settings. The pages still
   carry pages.dev canonical URLs at this point; that is expected.
7. **Set `SITE`.** Change the repository variable `SITE` to `https://unifiedpathoflight.com`,
   with no trailing slash.
8. **Redeploy.** Run the Deploy workflow from the Actions tab. The build now writes the
   canonical URLs, the sitemap, robots.txt and the llms files for the new origin, and the smoke
   test targets it. A green run is the proof that the move is complete.

If the apply fails on the zone lookup with a permission error, check that the token's Zone
Resources name this zone and that Zone, Zone, Read is present; do not answer it by granting all
zones or zone settings.

`www.unifiedpathoflight.com` serves the same site rather than redirecting, and so does the
pages.dev address, which a Pages project always keeps. Every page names the
apex as its canonical URL, so search engines treat the two as one. If the domain is ever to
carry email, set `site_domain_no_email` to `false` first and replace the four records.

The HSTS header stays as it is, without `includeSubDomains` and `preload`. The conditions for
changing that are recorded in step 8 of
[the launch plan](plans/2026-09-18-launch-readiness.md).

## Rolling back

A bad deployment: in the Cloudflare dashboard, Pages, the project, Deployments, choose the last
good one and roll back to it; then revert the pull request. Detaching the custom domain: set
`SITE` back to the pages.dev address and redeploy, then empty `SITE_DOMAIN` and apply. If a DS
record was published, remove it at the registrar first and wait a day before that apply;
turning DNSSEC off while the registrar still holds the DS record makes the domain stop
resolving. Removing everything: `tofu destroy`
in `infra/`, then revoke the API token and the R2 token.
