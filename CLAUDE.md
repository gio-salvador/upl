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
4. **The site is static and must run on the Cloudflare Pages free plan.** No server code, no
   Pages Functions, no client-side JavaScript unless the author approves it and the
   Content-Security-Policy in `site/public/_headers` is updated in the same change.
5. **Public tier from day one.** The repository is private for now and will be public. Treat
   every file as public: no secrets, no personal data beyond the author's public identity, no
   client or engagement material of any kind.
6. **Respect for the traditions named in the text.** Connecting text written for this
   repository describes other religions and their figures accurately and without ranking them.

7. **A teaching stays true to the core beliefs.** New or changed text under `content/` must not
   contradict the beliefs listed in [docs/doctrine-guardrails.md](docs/doctrine-guardrails.md).
   The ten core principles are the fixed centre: only the author adds, removes or redefines
   one.
8. **The traditions are kept in balance.** No tradition is the default lens. A page that
   illustrates a belief through a tradition uses at least two, or none, and draws across the
   range the teachings name (Christianity, Islam, Buddhism, Hinduism, Seicho-no-Ie and the
   others), varying which comes first. Pages dedicated to one figure or practice are the
   exception. The early text leans on Islam more than was intended; do not copy that pattern,
   and do not reword those pages unless the author asks (decision 2).
9. **The doctrine baseline is the author's.** Never run `scripts/check-doctrine.py` with
   `--accept-core` or `--waive-imbalance`, and never edit `scripts/doctrine-baseline.json` or
   loosen `scripts/doctrine-gate.json`, to make the gate pass. If the gate fails, fix the page
   or stop and ask.
10. **Every page renders correctly on phone and desktop.** No horizontal overflow from 320
    pixels wide upwards, navigation touch targets of at least 44 pixels. Never weaken
    `site/scripts/check-mobile.mjs` to make a page pass; fix the page.

## Working

- One gate entry point: `bash scripts/check.sh`. It runs the site checks, the doctrine gate
  and the vendored toolkit gates. CI runs the same script.
- Before writing or changing anything under `content/`, read
  [docs/doctrine-guardrails.md](docs/doctrine-guardrails.md), and check the result with
  `python3 scripts/check-doctrine.py --report`.
- Any change under `content/` also updates the cross-reference matrix before it merges: read
  [docs/cross-reference.md](docs/cross-reference.md), update `scripts/content-index.json` where
  the page touches a concept or a finding, then run
  `python3 scripts/check-content-index.py --record`. `--record` states that the pages were
  re-read against the matrix; never run it just to make the gate pass.
- The toolkit copy under `.claude/toolkit/` is vendored at a pinned version. Never edit it by
  hand; change it with `sct update`.
- Plans live in `docs/plans/` and follow the fleet plan template.
- Default voice for repository documentation: Giovanni. The teachings keep the voice of the
  founding paper.
