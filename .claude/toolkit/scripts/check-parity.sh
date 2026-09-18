#!/usr/bin/env bash
# Two-way parity between gitignored local layers and their committed templates (Goal G21).
#
# The .example convention only works in both directions. A gitignored file with no template
# leaves a newcomer guessing what must exist locally; a template with nothing gitignored is an
# invitation to commit the real thing next to it. The audit reported this; nothing gated it.
#
# Checked here, and deliberately NOT in the instance manifest's terms, so it works in any
# repository: every tracked `*.example` should have a gitignored sibling, and every path the
# repository's own declarations call local-only should have a template.
#
# Usage: check-parity.sh [--quiet]. Exit 0 clean, 1 finding.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
cd "$root" || exit 2
findings=0

# 1. Every committed template names a file the repository actually ignores.
while IFS= read -r tpl; do
  case "$tpl" in .claude/toolkit/*) continue ;; esac   # vendored: gated upstream
  real="${tpl%.example}"
  [ "$real" = "$tpl" ] && continue
  if git check-ignore -q "$real" 2>/dev/null; then continue; fi
  # A template whose real file is TRACKED is a different, worse problem: the real thing is in git.
  if git ls-files --error-unmatch "$real" >/dev/null 2>&1; then
    sct_block "$tpl has a template, but $real is TRACKED: the real file is in git"
  else
    sct_block "$tpl has no matching gitignore rule for $real: nothing stops the real file being committed"
  fi
  findings=$((findings+1))
done < <(sct_tracked "$root" | grep '\.example$' || true)

# 2. Every path the profile declares local-only has a template to copy from.
prof="$root/.claude/profile.yaml"
if [ -r "$prof" ]; then
  while IFS= read -r pth; do
    pth="$(printf '%s' "$pth" | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//')"
    [ -n "$pth" ] || continue
    case "$pth" in *.example) continue ;; esac
    if ! git ls-files --error-unmatch "$pth.example" >/dev/null 2>&1; then
      sct_block "profile declares $pth local-only, but $pth.example is not committed"
      sct_note "a newcomer cannot know what must exist locally without a template"
      findings=$((findings+1))
    fi
  done < <(awk '/^state:/{s=1;next} s&&/^[a-z]/{exit}
                s&&/^[[:space:]]+local_only:/{f=1;next} s&&/^[[:space:]]+[a-z_]+:/{f=0}
                s&&f&&/^[[:space:]]+-/{print}' "$prof" 2>/dev/null)
fi

[ "$findings" -gt 0 ] && { printf 'check-parity: %d finding(s)\n' "$findings" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-parity: templates and ignore rules agree\n'
exit 0
