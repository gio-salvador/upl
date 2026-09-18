# Unified Path of Light: working rules for this repository

Read [docs/conventions.md](docs/conventions.md) and
[docs/architecture.md](docs/architecture.md) first. The global rules in `~/.claude/CLAUDE.md`
apply in full. This file adds only what is specific to this repository.

## Locked decisions

1. **`content/` is the single canonical source of the teachings.** The site renders it. Nothing
   under `site/` may hold its own copy of a teaching.
2. **The wording of a teaching is the author's.** Never reword, shorten, expand or "improve"
   doctrine unless the author asks for that exact change. Structural work (moving, splitting,
   linking, front matter) must leave wording untouched. A wording change goes in its own pull
   request and is called out in the pull request body.
3. **No teaching is edited for search engines or language models.** Discoverability comes from
   structure and metadata.
4. **Every page renders correctly on phone and desktop.** No horizontal overflow from 320
   pixels wide upwards, navigation touch targets of at least 44 pixels. Never weaken
   `site/scripts/check-mobile.mjs` to make a page pass; fix the page.
5. **The site is static and must run on the Cloudflare Pages free plan.** No server code, no
   Pages Functions, no client-side JavaScript unless the author approves it and the
   Content-Security-Policy in `site/public/_headers` is updated in the same change.
6. **Public tier from day one.** The repository is private for now and will be public. Treat
   every file as public: no secrets, no personal data beyond the author's public identity, no
   client or engagement material of any kind.
7. **Respect for the traditions named in the text.** Connecting text written for this
   repository describes other religions and their figures accurately and without ranking them.

## Working

- One gate entry point: `bash scripts/check.sh`. It runs the site checks and the vendored
  toolkit gates. CI runs the same script.
- The toolkit copy under `.claude/toolkit/` is vendored at a pinned version. Never edit it by
  hand; change it with `sct update`.
- Plans live in `docs/plans/` and follow the fleet plan template.
- Default voice for repository documentation: Giovanni. The teachings keep the voice of the
  founding paper.
