# Security

What this repository protects and how to raise a problem. For maintainers and contributors.

## Model

The repository holds public-intent text and a static website. It stores no secrets, no
personal data, and no credentials, and the site has no server-side code, forms, or accounts.
The main risks are an unwanted change to the canonical text and a compromised site dependency.

## Controls

- Changes land through pull requests with signed commits.
- Site dependencies are pinned to exact versions in `site/package.json` and locked in
  `site/package-lock.json`.
- The site sends strict response headers from `site/public/_headers`: a Content-Security-Policy
  starting from `default-src 'none'` with no `'unsafe-inline'`, HSTS, and cross-origin
  isolation headers. Stylesheets are always external files
  (`inlineStylesheets: 'never'` in `site/astro.config.mjs`) so the policy holds. The site loads
  no executable scripts and no third-party resources. The policy is lifted for `/paper/*` only,
  so browsers can display the PDF.
- Text from `content/` is never trusted to be markup-safe. Astro escapes it in pages and
  attributes, and the JSON-LD blocks escape `<` so a title cannot close the block.
- A CI or Cloudflare build without the `SITE` variable fails, so localhost addresses can never
  be published.
- `/.well-known/security.txt` points reporters at the private advisory form.
- New dependency versions are held back for 7 days (`site/.npmrc` and
  `.github/dependabot.yml`), which keeps freshly published malicious releases out.
- Cloudflare credentials exist only as GitHub secrets. The API token is scoped to Cloudflare
  Pages on one account and, once the custom domain is attached, to reading the one zone and
  editing its DNS. OpenTofu state is stored outside the repository, and `infra/.gitignore`
  keeps state and variable files out of git.
- The custom domain's zone is signed with DNSSEC and publishes a null MX, SPF `-all`, an empty
  DKIM key and DMARC `p=reject`, because the domain sends no email (`infra/domain.tf`). HSTS
  omits `includeSubDomains` and `preload` until every subdomain is known to be HTTPS-only.
- Deploys run only from `main` and from branches of this repository; pull requests from forks
  never receive secrets. The branch name used for a preview alias is reduced to safe characters
  before use.
- Never commit a secret, token, or credential, even as an example.

## Gates and scans

| Gate | Where |
| ---- | ----- |
| Markdown lint, site build, link gate and SEO gate (`scripts/check.sh site`) | `.github/workflows/ci.yml`, job `build` |
| Every page rendered at four widths: overflow, viewport, landmark, touch targets. Skipped on a pull request that changes nothing visual; always run on `main` | `.github/workflows/ci.yml`, job `mobile` |
| Toolkit gates: docs, doc claims, plan structure, hardcoded paths and secrets, public readiness, and the sensitive-token scan when the `SENSITIVE_TOKENS` secret is set | `.github/workflows/ci.yml`, job `gates`, running `scripts/check.sh gates` |
| Site gate before any upload, then a smoke test of the live headers and key addresses | `.github/workflows/deploy.yml` |
| OpenTofu format and validate; plan and apply once enabled | `.github/workflows/iac.yml` |
| Secret scan of the full history (gitleaks) | `.github/workflows/ci.yml`, job `gitleaks` |
| Dependency CVE scan (OSV-Scanner), weekly and on every push to `main`; fails on a finding | `.github/workflows/security.yml` |
| CodeQL and OpenSSF Scorecard | `security.yml` and `scorecard.yml`; both run only once the repository is public |

All actions are pinned by commit SHA, and no checkout leaves credentials behind.

## Known gaps

Recorded by the security and gitops audits of 2026-09-18, and closed by the owner, not by code:

- **No server-side protection of `main`.** GitHub refuses rulesets, secret scanning and push
  protection on a private repository on the free plan. Until the repository is public, only the
  local hooks enforce pull-request-only and signed commits.
- **No licence.** The author has not chosen one. It must exist before the repository is public.
- **Sensitive-token scan in CI is off until the `SENSITIVE_TOKENS` secret is set.** The local
  pre-push hook runs the scan meanwhile.

The steps that close them are in [runbook-go-live.md](runbook-go-live.md).

## Reporting

Follow [SECURITY.md](../SECURITY.md).
