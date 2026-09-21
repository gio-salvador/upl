# Conventions

The naming and project conventions for this repository, and where each is enforced. For
contributors.

## Naming

- Files and folders are kebab-case. `README.md` is the only uppercase name under `content/`
  and `docs/`. Enforced by review.
- The five top-level parts of `content/` carry a numeric prefix (`1-foundations`). Nothing
  below them does.
- Everything written for Claude Code in this repository carries the `upl-` prefix: agents
  (`.claude/agents/upl-*.md`), skills (`.claude/skills/upl-*/`), rules, commands and anything
  of the kind added later. The prefix keeps a project-local tool from shadowing a fleet tool,
  which carries `sc-`. The toolkit's own manifests (`content-review.yaml` and the others) and
  the vendored `.claude/toolkit/` keep the names the toolkit reads them by. Enforced by review.
- Branches and commits follow the conventional-commit style (`feat:`, `fix:`, `docs:`).
  Changes land through pull requests, never directly on `main`. Enforced by the local git
  hooks and, once enabled, the branch ruleset.

## Content pages

- Every page under `content/` has `title` and `order` front matter. Enforced by the site
  build, which fails on a missing or mistyped field (`site/src/content.config.ts`).
- The H1 matches `title`. One H1 per page.
- `description` front matter is optional and overrides the generated page description.
- Every folder has a `README.md` listing its pages in `order`. Enforced by review.
- Every page must render without horizontal overflow from 320 pixels wide upwards, with touch
  targets of at least 44 pixels for navigation. Enforced by `site/scripts/check-mobile.mjs` in CI.
- Markdown style is enforced by markdownlint (`.markdownlint-cli2.jsonc`) in CI.
- Links between pages are relative and point at the `.md` file.

## Doctrine and balance

- A page under `content/` must not contradict the core beliefs, and must not lean on one
  tradition. The rules are in [doctrine-guardrails.md](doctrine-guardrails.md). Enforced by
  `scripts/check-doctrine.py` in `scripts/check.sh`, and by review.
- The pages under `content/1-foundations/` and `content/2-doctrine/` are locked by
  fingerprint. A change to one is recorded by the author. Enforced by the same gate.

## Cross-references

- Every concept has one owner page, every page has a status, and every known overlap between
  pages is a recorded finding. The index is `scripts/content-index.json` and the readable view
  is [cross-reference.md](cross-reference.md). Enforced by `scripts/check-content-index.py` in
  `scripts/check.sh`.
- A new or changed page under `content/` fails the gate until it has been re-read against the
  matrix and recorded with `--record`, so the matrix is updated before any merge.

## Sources

- Every outside source used to check or support a statement is recorded once in
  [sources.md](sources.md) under a permanent id, and pages cite it by that id. The rule is in
  [doctrine-guardrails.md](doctrine-guardrails.md), section 6. Enforced by
  `scripts/check-sources.py` in `scripts/check.sh`, and by the `citation` lens of the content
  review.

## Locked decisions

The ten decisions that must not be broken (among them: single source, no rewording of
teachings, static site, public tier, true to the core beliefs, balance between traditions, the
author's doctrine baseline, correct rendering on phone and desktop) are in `CLAUDE.md` at the
repository root. Enforced by review and by the
`process-locked` lens in `.claude/plan-review.yaml`.

## Single source

`content/` is the only place the teachings are written. The site renders it and must not hold
its own copy of any teaching.

## Writing

British spelling, plain language, and no em or en dashes. The text taken from the founding
paper keeps the author's wording; only typographical slips were corrected.
