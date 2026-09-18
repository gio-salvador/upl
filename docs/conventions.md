# Conventions

The naming and project conventions for this repository, and where each is enforced. For
contributors.

## Naming

- Files and folders are kebab-case. `README.md` is the only uppercase name under `content/`
  and `docs/`. Enforced by review.
- The five top-level parts of `content/` carry a numeric prefix (`1-foundations`). Nothing
  below them does.
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

## Locked decisions

The decisions that must not be broken (single source, no rewording of teachings, static site,
public tier, true to the core beliefs, balance between traditions) are in `CLAUDE.md` at the
repository root. Enforced by review and by the
`process-locked` lens in `.claude/plan-review.yaml`.

## Single source

`content/` is the only place the teachings are written. The site renders it and must not hold
its own copy of any teaching.

## Writing

British spelling, plain language, and no em or en dashes. The text taken from the founding
paper keeps the author's wording; only typographical slips were corrected.
