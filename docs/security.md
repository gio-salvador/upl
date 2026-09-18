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
- New dependency versions are held back for 7 days (`site/.npmrc` and
  `.github/dependabot.yml`), which keeps freshly published malicious releases out.
- Never commit a secret, token, or credential, even as an example.

## Gates and scans

| Gate | Where |
| ---- | ----- |
| Markdown lint, site build and link gate | `.github/workflows/ci.yml`, job `build` |
| Secret scan of the full history (gitleaks) | `.github/workflows/ci.yml`, job `gitleaks` |
| Dependency CVE scan (OSV-Scanner), weekly | `.github/workflows/security.yml` |
| CodeQL and OpenSSF Scorecard | `security.yml` and `scorecard.yml`; both run only once the repository is public |

All actions are pinned by commit SHA.

## Reporting

Follow [SECURITY.md](../SECURITY.md).
