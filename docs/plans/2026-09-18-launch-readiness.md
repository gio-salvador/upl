# Take the UPL repository from a local branch to a secured, discoverable site that deploys itself

**Status: in progress.** Requested 2026-09-18. This file records the design, the sequence and
the open decisions, so "not yet" stays a decision rather than becoming forgetting. Step status
is kept in the Sequence table and updated as steps land.

## What was asked for

In the requester's words, across four messages on 2026-09-18:

1. "what about IaC and pushing code to cloudflare autonomously when it hits main?"
2. "what about importing tools from salvadorcloud-tools?" (read as the salvadorcloud-ai-toolkit
   repository, the only toolkit repository on this machine)
3. "current website links are broken due to the lack of trailing slashes, fix it."
4. "also fix all the security and seo and GEO, AEO, AIO, LLMO"
5. "Create a plan to execute everything you need so you don't get lost."

Standing constraints from earlier the same day: the site must be static and must run on the
Cloudflare Pages free plan; the repository will be made public once the content is ready.

## Goals

1. **Links never break silently.** Serves request 3. A broken or slash-less internal link fails
   a gate before it reaches a reader.
2. **A merge to `main` publishes the site with no human step.** Serves request 1 and the
   PR-only GitOps rule: the only way to change production is a reviewed merge.
3. **Cloudflare configuration is code in this repository.** Serves request 1. Nothing about the
   Pages project is set by hand in a dashboard, so it can be reviewed, reverted and rebuilt.
4. **The repository runs the toolkit's gates at a pinned version.** Serves request 2. Toolkit
   upgrades arrive as reviewable diffs.
5. **The site is as easy for a search engine or a language model to read, cite and attribute as
   it is for a person.** Serves request 4 (SEO, GEO, AEO, AIO, LLMO are treated as one goal:
   machine-readable, attributable, well-structured text).
6. **The security posture meets the public tier before the repository is public.** Serves
   request 4 and the public-tier GitOps rule.

Non-goals:

- **No custom domain, DNS, DNSSEC or email records in this plan.** They are the obvious next
  step after the Pages project exists, and they are excluded because no domain has been chosen
  (D3). The design leaves room for them; step 8 is reserved.
- **No redesign of the site.** Reading components and visual identity are a separate piece of
  work. This plan changes what machines see, not what the pages look like.
- **No content changes.** The teachings are not edited for keywords. Discoverability comes from
  structure and metadata, never from rewriting doctrine.

## What already exists, and must not be rebuilt

| Need | Already present |
| ---- | --------------- |
| Static build, trailing-slash routes, 404 page | `site/astro.config.mjs`, `site/src/pages/404.astro` |
| Strict response headers | `site/public/_headers` |
| Title, description, canonical, Open Graph, breadcrumb JSON-LD, sitemap, robots | `site/src/components/seo/`, `site/src/lib/structured-data.ts`, `site/src/pages/robots.txt.ts` |
| CI: markdown lint, build, gitleaks; weekly OSV, CodeQL and Scorecard once public | `.github/workflows/` |
| Dependabot with a 7-day cooldown, npm cooldown, exact pins | `.github/dependabot.yml`, `site/.npmrc` |
| Local hooks at public tier | attached by the toolkit's setup-gitops.sh on 2026-09-18 |
| Toolkit profile and lockfile | `.claude/profile.yaml`, `.claude/toolkit.lock` (see D6) |
| Deploy and IaC reference implementations | salvador-cloud-site: its deploy and iac workflows and its infra folder (MIT code) |
| Skills and reviewer agents | installed machine-wide by the toolkit; this repository only needs manifests |

## What is genuinely missing

1. A gate that fails on a broken or slash-less internal link, and a fix for the stale dev cache
   that caused the report.
2. Any commit. All work so far is uncommitted on `feat/repo-structure`.
3. OpenTofu configuration for the Cloudflare Pages project, and a state backend.
4. A deploy workflow that publishes on push to `main`.
5. Vendored toolkit gates in CI, and per-skill manifests for content review, docs sync, plan
   review and PR opening.
6. Machine-facing discoverability: llms.txt, a full-text file for language models, markdown
   alternates of each page, explicit AI-crawler policy in robots.txt, Article-level JSON-LD,
   a social sharing image.
7. Public-tier security items: security.txt, a branch ruleset on `main`, a security audit of
   the repository, a post-deploy header smoke test, a licence.

## The design

### Links (goal 1)

Root cause, established by crawling a fresh dev server (81 URLs, none broken): the pages were
correct, but Astro caches rendered markdown and does not invalidate it when the link rewriter
or the trailing-slash setting changes. A dev server that was running across that change kept
serving old links, which return 404 under `trailingSlash: 'always'`.

Two parts: the cache is cleared before every dev and build run, and a link gate walks the built
HTML after every build, failing on any internal link that does not resolve to a built file or
any page link without a trailing slash. The gate runs in CI.

### Deploy on merge (goals 2 and 3)

```text
merge to main -> GitHub Actions: npm ci, lint, build, link gate
              -> wrangler pages deploy site/dist (direct upload)
              -> smoke test: headers, sitemap, llms.txt, a deep page
```

The Pages project is a direct-upload project created by OpenTofu, with no git source. This is
the model salvador-cloud-site settled on: a git-connected project builds on Cloudflare's side
and conflicts with a deploy workflow. It replaces the dashboard git-build instructions now in
`docs/features-and-usage.md`.

The deploy job skips cleanly, with a notice, while the Cloudflare secrets are absent, so CI
stays green before the account is wired up. The build always runs.

A new infra folder holds: providers (Cloudflare provider pinned exactly), an S3-compatible
backend on R2, variables, and the Pages project with `SITE` set per environment. A new iac
workflow runs fmt and validate on every change to that folder; plan on pull requests and apply
on `main` are gated behind a repository variable until state and secrets exist.

Pull requests get a preview deployment on a branch alias, so a change to the teachings can be
read as a site before it is merged.

### Toolkit (goal 4)

`sct vendor --profile gates` places a pinned copy of the gates under `.claude/`. CI gains a job
that runs them (docs structure, doc claims, plan structure, public readiness). Manifests to add
under `.claude/`: content-review (lenses: consistency, editor, titles, citation, ip,
audience-reader, domain-accuracy), docs-sync, plan-review, open-pr. No skill or agent is copied
into this repository; they stay machine-wide.

### Discoverability (goal 5)

- llms.txt at the site root: what UPL is, then a linked outline of every section, generated
  from `content/` at build time.
- llms-full.txt: the whole text in reading order, one file, generated.
- A markdown alternate for every page (the source file, front matter stripped) and a
  `rel="alternate" type="text/markdown"` link in each page head.
- robots.txt names the main AI crawlers explicitly and allows them: the aim of a religion's
  text is to be read and cited. D5 records this as a decision because it is reversible only in
  part: text already crawled stays crawled.
- JSON-LD: an Article block per page (headline, description, author, inLanguage, isPartOf,
  the breadcrumb), and a CreativeWork block for the founding paper. No dates are invented: a
  published date is emitted only where front matter carries one.
- A single default social image, generated once and committed, plus `og:image` tags.
- Answer-engine structure comes from what the content already has: one question-shaped idea per
  page, a descriptive H1, a first paragraph that states the point. The plan adds a check that
  every page has a non-empty description of sensible length, not a rewrite of any page.

### Security (goal 6)

- security.txt under `.well-known`, pointing at the GitHub advisory form, with an expiry.
- Run the sc-security-audit skill (in-house posture) and the sc-gitops-audit skill; findings
  become fixes in the same step or recorded decisions.
- Branch ruleset on `main`: pull request required, required checks, signed commits, no force
  push, no deletion. If the GitHub plan refuses it on a private repository, that is recorded as
  a major gap that closes when the repository goes public, not as a pass.
- Post-deploy smoke test asserts the CSP, HSTS and frame headers on the live site.
- The npm audit finding in the markdown linter's dependency is tracked by Dependabot; it is
  dev-only and not reachable from the built site.
- Run the toolkit's public-readiness scan before visibility changes.

## Open decisions

- **D1 TAKEN: deploy by GitHub Actions direct upload, not Cloudflare's git build.** The request
  is for deployment as part of the reviewed pipeline, with smoke tests and IaC; the git build
  cannot run the link gate first and conflicts with an IaC-managed direct-upload project.
- **D2 TAKEN: OpenTofu with the Cloudflare provider, state in R2.** Matches the reference
  implementation, and R2's free allowance covers a state file many times over.
- **D3 OPEN: which Cloudflare account, and what project name.** Recommendation: a project named
  unified-path-of-light in your personal Cloudflare account, not the Salvador Cloud Ltd one,
  with its own state bucket. A religion's site should not sit inside a company's account or
  share its state. The code takes both as variables, so this blocks only the first apply.
- **D4 OPEN: domain.** None chosen. The site works on the pages.dev address meanwhile. Step 8
  waits on this.
- **D5 OPEN: AI crawlers allowed by name.** Recommendation: allow. Reversing it later stops new
  crawling but does not recall what was read.
- **D6 TAKEN, with a correction:** `sct init` was run on 2026-09-18 by mistake, while asking it
  for help text; it has no help flag and initialised instead. The result is what this plan
  wanted anyway and validates, so it is kept. The profile records your name, email and signing
  key id, which will be public with the repository; they are already public in the signed
  commits, so this adds nothing new, but it is yours to veto.
- **D7 OPEN: licence.** Recommendation: CC BY-SA 4.0 for `content/` and `paper/`, MIT for the
  site code, stated in one LICENSE file with two sections, as salvador-cloud-site does.
  Language models and search engines treat a clear licence as a signal that text may be quoted.
- **D8 OPEN: GitHub CLI account.** The active `gh` account on this machine is gio-deone, which
  cannot see gio-salvador/upl. Opening pull requests needs `gh auth switch`, which also
  affects your other sessions, so it is yours to do or to approve.

## Sequence

One pull request per step. Each leaves `main` green.

| Step | Pull request | Needs from you | Status |
| ---- | ------------ | -------------- | ------ |
| 1 | Repository structure, content, site, imported scaffolding, link gate, cache fix, toolkit profile | approval to commit and open it; D8 | merged 2026-09-18, pull request 1 |
| 2 | Toolkit: vendored gates, CI gate job, manifests, CLAUDE.md, single check entry point | nothing | in review |
| 3 | Discoverability: llms files, markdown alternates, robots policy, Article JSON-LD, social image, description check | D5 | in review, built on the recommendation (allow) |
| 4 | Security: security.txt, audit findings, LICENSE, readiness scan | D7 | not started |
| 5 | IaC: infra folder, iac workflow (fmt and validate live; plan and apply gated off) | nothing to merge | not started |
| 6 | Deploy workflow with credential skip, preview deployments, smoke test; docs updated to the new model | nothing to merge | not started |
| 7 | Go live: create the API token, account id and state secrets; first apply; enable the gates; set the branch ruleset | D3, and the secrets, which only you can create | not started |
| 8 | Custom domain, DNS, HSTS upgrade | D4 | reserved |

Load-bearing order: 1 before everything (nothing can be reviewed until it is committed). 5
before 7 (apply needs the code). 6 before 7 (the first deploy needs a project, and the project
needs the workflow's name for it). 3 and 4 are independent of 5 and 6 and can land in either
order.

## Cross-dependencies

| Edge | Why it is hard |
| ---- | -------------- |
| 6 depends on 5 for the project name | The deploy command and the OpenTofu resource must name the same project; it is a single variable read by both. |
| 7 depends on a token with no IP lock | Runners have changing addresses. The reference repository hit this: its local token was IP-locked and unusable from CI. |
| Smoke test in 6 depends on `SITE` | Until a domain exists it must target the pages.dev address, so the address is a variable, not a literal. |
| Inside 3: llms files depend on the route map | They must use the same path-to-route function as the pages, or they will link to addresses that do not exist. The link gate is extended to cover them. |
| Inside 4: LICENSE before readiness scan | The scan treats a missing licence as a finding. |

## Risks

- **A deploy publishes unreviewed doctrine.** Survivable because `main` is PR-only and the
  ruleset (step 7) makes that server-side, not just a local hook.
- **A leaked Cloudflare token.** Scoped to Pages edit on one account, stored only as a GitHub
  secret, never in a file; gitleaks runs on every push. Rotation is one command.
- **State file loss.** One resource; it can be re-imported in a minute. Accepted.
- **The Cloudflare provider's next major changes resource shapes.** Pinned exactly; Dependabot
  raises the bump as a reviewable diff.
- **llms.txt is a convention, not a standard.** Cheap to emit, harmless if ignored. Accepted.
- **Free-plan limits** (as of September 2026: 500 Pages builds a month, which direct upload
  does not consume, and 20,000 files per deployment against about 250 after step 3). Accepted.

## What this plan does not do

It does not choose a domain, a licence or a Cloudflare account for you. It does not create
credentials or type them anywhere. It does not make the repository public. It does not edit the
teachings. It does not redesign the site.

## Success criteria

The one that matters most: **a merged pull request that changes one word in `content/` is live
on the public address within ten minutes, with no manual step, and the smoke test proves it.**

- `npm --prefix site run build && npm --prefix site run check:links` exits 0, and exits 1 when
  any internal link in the build is edited to drop its slash. (Proven on 2026-09-18.)
- `sct validate` reports no blocking finding.
- `curl -sI` on the live site shows the CSP, HSTS and `X-Frame-Options: DENY` headers.
- The live llms.txt lists every page in `content/`, and every link in it returns 200.
- Google's Rich Results test reads the Article and breadcrumb blocks on a deep page with no
  error.
- `tofu plan` on `main` reports no changes after apply: the dashboard and the code agree.

Negative criteria: no gate was loosened or skipped to get green; no secret appears in any file
or log; no second copy of the teachings exists outside `content/` except generated build
output; no teaching was reworded for search.

Rollback: steps 1 to 6 are each a single revert. Step 7 is not: the Pages project, the token
and the secrets exist outside git and are removed with `tofu destroy` and by revoking the
token.

## Acceptance

The repository is public-tier compliant and ready to be made public. Merging to `main` builds,
checks and publishes the site to Cloudflare Pages on the free plan. The Pages project is defined
in code. The toolkit's gates run in CI at a pinned version. A person, a search engine and a
language model can each find any teaching, read it in a form suited to them, and see who wrote
it and under what licence.
