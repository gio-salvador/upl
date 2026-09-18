#!/usr/bin/env bash
# The single gate entry point for this repository. CI and the pre-PR check both run it.
#   scripts/check.sh            everything
#   scripts/check.sh gates      only the vendored toolkit gates (no Node needed)
#   scripts/check.sh site       only the site checks
#   scripts/check.sh mobile     only the mobile and desktop rendering gate, always
# Under `all` the rendering gate is skipped when scripts/visual-changed.sh finds nothing visual.
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
  npm --prefix site run check:contrast
fi

# The rendering gate is the slow one. Under `all` it is skipped when nothing that can affect
# rendering has changed since main; `mobile` always runs it.
run_mobile=0
[ "$what" = mobile ] && run_mobile=1
if [ "$what" = all ] && bash scripts/visual-changed.sh; then run_mobile=1; fi
if [ "$run_mobile" = 1 ]; then
  [ -d site/dist ] || npm --prefix site run build
  npm --prefix site run check:mobile
fi

if [ "$what" = all ] || [ "$what" = gates ]; then
  # The doctrine gate: core beliefs, balance between traditions, locked core pages.
  PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -q -s scripts/tests
  python3 scripts/check-doctrine.py
  # The cross-reference gate: one owner per concept, recorded overlaps, no page changed unseen.
  python3 scripts/check-content-index.py
  python3 "$T/config/docs/check-docs.py" --root . --exclude 'plans/*'
  bash "$T/scripts/check-doc-claims.sh"
  bash "$T/scripts/check-plan-structure.sh"
  bash "$T/gitops/lib/check-hardcoding.sh"
  bash "$T/scripts/check-public-ready.sh"
fi
echo "check: $what passed"
