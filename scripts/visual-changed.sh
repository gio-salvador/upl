#!/usr/bin/env bash
# Decides whether the rendering gate (site/scripts/check-mobile.mjs) needs to run.
# Exit 0 = something that can change how a page renders has changed, run the gate.
# Exit 1 = nothing visual changed, the gate may be skipped.
#
#   scripts/visual-changed.sh [base-ref]      base-ref defaults to origin/main
#
# Compared: commits since the merge base with base-ref, plus uncommitted and untracked work.
# FAILS OPEN: if the base cannot be resolved, or anything else is uncertain, it says "run".
# A skipped check that should have run is the failure this guards against.
#
# What counts as visual: the teachings (a long word or a new page changes layout), everything
# the site is built from, and this decision itself. What does not: docs, plans, infra,
# workflows other than ci.yml, the toolkit, repository scaffolding.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 0

VISUAL='^(content/|site/|scripts/visual-changed\.sh$|scripts/check\.sh$|\.github/workflows/ci\.yml$)'
# Inside site/, files that cannot affect a rendered page.
NOT_VISUAL='^site/(scripts/(check-links|check-seo|generate-og|sync-paper|clear-content-cache)\.mjs|src/pages/(robots|llms|llms-full)\.txt\.ts|src/pages/.*index\.md\.ts|src/lib/(machine-text|structured-data|describe)\.ts|src/components/seo/|public/(_headers|\.well-known/|og-default\.png)|\.npmrc|\.gitignore)'

base="${1:-origin/main}"
if ! mb="$(git merge-base "$base" HEAD 2>/dev/null)"; then
  echo "visual-changed: cannot resolve '$base'; running the gate to be safe"
  exit 0
fi

changed="$( { git diff --name-only "$mb" HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u )"
relevant="$(printf '%s\n' "$changed" | grep -E "$VISUAL" | grep -Ev "$NOT_VISUAL" || true)"

if [ -n "$relevant" ]; then
  echo "visual-changed: $(printf '%s\n' "$relevant" | wc -l | tr -d ' ') file(s) can affect rendering, for example: $(printf '%s\n' "$relevant" | head -3 | tr '\n' ' ')"
  exit 0
fi
echo "visual-changed: nothing that affects rendering changed since $base; the rendering gate may be skipped"
exit 1
