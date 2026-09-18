#!/usr/bin/env bash
# The single gate entry point for this repository. CI and the pre-PR check both run it.
#   scripts/check.sh            everything
#   scripts/check.sh gates      only the vendored toolkit gates (no Node needed)
#   scripts/check.sh site       only the site checks
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
what="${1:-all}"
T=.claude/toolkit

if [ "$what" = all ] || [ "$what" = site ]; then
  [ -d site/node_modules ] || npm --prefix site ci
  npm --prefix site run lint:md
  npm --prefix site run build
  npm --prefix site run check:links
  npm --prefix site run check:seo
fi

if [ "$what" = all ] || [ "$what" = gates ]; then
  # The doctrine gate: core beliefs, balance between traditions, locked core pages.
  PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -q -s scripts/tests
  python3 scripts/check-doctrine.py
  python3 "$T/config/docs/check-docs.py" --root . --exclude 'plans/*'
  bash "$T/scripts/check-doc-claims.sh"
  bash "$T/scripts/check-plan-structure.sh"
  bash "$T/gitops/lib/check-hardcoding.sh"
  bash "$T/scripts/check-public-ready.sh"
fi
echo "check: $what passed"
