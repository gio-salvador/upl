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

## Rolling back

A bad deployment: in the Cloudflare dashboard, Pages, the project, Deployments, choose the last
good one and roll back to it; then revert the pull request. Removing everything: `tofu destroy`
in `infra/`, then revoke the API token and the R2 token.
