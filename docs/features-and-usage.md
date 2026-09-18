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
never leaves stale links behind. Both outputs are ignored by git.

## Check your work

```bash
bash scripts/check.sh
```

That one command runs everything CI runs. `bash scripts/check.sh site` runs only the three site
checks below, and `bash scripts/check.sh gates` runs only the toolkit gates.

```bash
npm --prefix site run lint:md
npm --prefix site run build
npm --prefix site run check:links
```

`check:links` walks the built pages and fails if any internal link does not resolve or any
page link lacks its trailing slash. `lint:md` lints every markdown file in the repository against `.markdownlint-cli2.jsonc`. CI
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
characters. To override it, add a `description` line to the page's front matter.

## Deploy to Cloudflare Pages

The site is fully static: the build produces plain HTML and CSS with no server code and no
client-side JavaScript, so it fits the Cloudflare Pages free plan (as of September 2026: up to
20,000 files and 25 MiB per file; the build is about 80 files).

Connect the GitHub repository in the Cloudflare dashboard with these build settings:

| Setting | Value |
| --------- | ------- |
| Framework preset | Astro |
| Root directory | `site` |
| Build command | `npm run build` |
| Build output directory | `dist` |

Also set the environment variable `SITE` to the public origin (for example
`https://example.org`). Canonical URLs, the sitemap, and `robots.txt` are built from it;
without it they point at `localhost`.

Cloudflare clones the whole repository, so the build can still read `../content` and
`../paper`. The Node.js version comes from `site/.node-version`. Response headers are set in
`site/public/_headers`, and `site/src/pages/404.astro` becomes the `404.html` that Pages serves
for unknown paths.
