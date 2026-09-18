# Features and usage

How to work with this repository: reading the text, changing it, and running the website. For
contributors and maintainers.

## Read the teachings

Start at [content/README.md](../content/README.md). Every folder has a `README.md` that
introduces the section and lists its pages in order, so the whole text can be browsed on GitHub
without the website.

## Add a page

1. Create a kebab-case `.md` file in the right section folder under `content/`.
2. Give it front matter and a matching H1:

   ```markdown
   ---
   title: "Forgiveness"
   order: 4
   ---

   # Forgiveness
   ```

3. Add it to the numbered list in that folder's `README.md`, at the position matching `order`.

The website picks the page up on the next build. Nothing in `site/` needs to change.

## Add a section

Create a folder with a `README.md` (front matter, H1, a short introduction, and the list of its
pages), then list the folder in its parent's `README.md`.

## Run the website

```bash
npm --prefix site install
npm --prefix site run dev
```

`npm --prefix site run build` writes the static site to a dist folder inside `site/`. Both
commands first copy `paper/` into the site's public folder, so the founding paper can be
downloaded from the site, and clear Astro's content cache, so a change to the link rewriter
never leaves stale links behind. Dev and build keep separate caches and each clears only its
own, so a build never disturbs a running dev server. Both outputs are ignored by git.

## Check your work

```bash
bash scripts/check.sh
```

That one command runs everything CI runs. `bash scripts/check.sh site` runs only the first four site
checks below, `bash scripts/check.sh mobile` only the rendering gate, and `bash scripts/check.sh gates` runs only the toolkit gates.

```bash
npm --prefix site run lint:md
npm --prefix site run build
npm --prefix site run check:links
npm --prefix site run check:seo
npm --prefix site run check:mobile
```

`check:links` walks the built pages, the markdown alternates and the llms files, and fails if
any internal link does not resolve or any page link lacks its trailing slash. `check:mobile` opens every built page in headless Chromium at 320, 375, 768 and 1280 pixels
wide and fails on horizontal overflow at any width, a missing viewport tag or `main` landmark,
or, on phone widths, a navigation link under 44 pixels tall or a breadcrumb link under 24. It
needs Chromium once: `npx --prefix site playwright install chromium`. `check:seo` fails
if any page lacks a title, a single H1, a description of 50 to 200 characters, a canonical URL,
a social image, valid JSON-LD or its markdown alternate, or if `llms.txt` does not list every
page. It checks structure and metadata only, never the wording of a teaching. `lint:md` lints every markdown file in the repository against `.markdownlint-cli2.jsonc`. CI
runs all three on every pull request.

## Toolkit gates and skills

The repository adopts the salvadorcloud-ai-toolkit at a pinned version: `.claude/toolkit.lock`
records the version and `.claude/toolkit/` holds the vendored gates. They check the docs
structure, that every path the docs name exists, plan structure, hardcoded paths and secrets,
and public readiness. Move to a newer toolkit version with `sct update`, which produces a
reviewable diff; never edit the vendored copy by hand.

Manifests under `.claude/` configure the toolkit's skills for this repository:
`content-review.yaml` (review lenses for the teachings and for the docs), `docs-sync.yaml`,
`plan-review.yaml` and `open-pr.yaml`.

## Page descriptions

Each page's search and social description is the first paragraph of its text, cut to about 160
characters. To override it, add a `description` line to the page's front matter. A page whose first
paragraph is shorter than 50 characters gets a standard closing sentence appended.

To redraw the social sharing image after a design change:

```bash
node site/scripts/generate-og.mjs
```

## Deploy to Cloudflare Pages

Deployment is automatic: a merge to `main` runs `.github/workflows/deploy.yml`, which runs the
full site gate, uploads the built site to Cloudflare Pages by direct upload, and smoke-tests the
live address. A pull request from a branch of this repository gets a preview deployment on a
branch alias, so a change can be read as a site before it is merged. Nothing is uploaded if any
gate fails.

The site is fully static: plain HTML and CSS with no server code and no client-side JavaScript,
so it fits the Cloudflare Pages free plan (as of September 2026: up to 20,000 files and 25 MiB
per file; the build is about 250 files). Direct uploads do not use the plan's monthly build
allowance.

The Pages project itself is defined in `infra/` and managed by `.github/workflows/iac.yml`. The
one-time account setup is in [runbook-go-live.md](runbook-go-live.md). Until it is done, the
workflow builds and checks the site, skips the upload with a notice, and stays green.

The public origin comes from the `SITE` repository variable; canonical URLs, the sitemap and
`robots.txt` are built from it. Response headers are set in `site/public/_headers`, and
`site/src/pages/404.astro` becomes the `404.html` that Pages serves for unknown paths. The
Node.js version comes from `site/.node-version`.
