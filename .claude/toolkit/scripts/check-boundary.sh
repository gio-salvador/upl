#!/usr/bin/env bash
# The toolkit and its instance overlay share no file (Goal G2).
#
# The whole arrangement rests on one claim: a rule is defined in exactly one place. If a path
# exists in both the toolkit and the overlay, there are two definitions and they will disagree,
# quietly, at the worst moment. That claim was made in a decision log and checked by nobody.
#
# It also verifies the inventory is COMPLETE: every file the overlay tracks is declared in
# instance-manifest.yaml. An inventory missing five files is not an inventory, it is a list
# (TK-076).
#
# The overlay is located through the config home's `instance-path`, written by install.sh. With
# no overlay installed there is nothing to compare and the check says so rather than passing
# silently.
#
# Usage: check-boundary.sh [--quiet]. Exit 0 clean, 1 finding, 2 cannot check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2

if [ ! -r "$root/instance-manifest.yaml" ]; then
  [ "$quiet" -eq 1 ] || printf 'check-boundary: no instance inventory; not the toolkit, nothing to police\n'
  exit 0
fi

cfg="${CLAUDE_CONFIG_HOME:-$HOME/.claude}"
overlay=""
[ -r "$cfg/instance-path" ] && overlay="$(cat "$cfg/instance-path")"
if [ -z "$overlay" ] || [ ! -d "$overlay" ]; then
  [ "$quiet" -eq 1 ] || printf 'check-boundary: no instance overlay installed; nothing to compare\n'
  exit 0
fi
[ -d "$overlay/.git" ] || overlay_root="$(git -C "$overlay" rev-parse --show-toplevel 2>/dev/null)"
overlay_root="${overlay_root:-$overlay}"
rel="${overlay#"$overlay_root"/}"

findings=0
# 1. No shared paths.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="${f#"$rel"/}"
  if git -C "$root" ls-files --error-unmatch "$p" >/dev/null 2>&1; then
    sct_block "defined in BOTH the toolkit and the overlay: $p"
    sct_note "two definitions of one thing; they will disagree, quietly, at the worst moment"
    findings=$((findings+1))
  fi
done < <(git -C "$overlay_root" ls-files "$rel" 2>/dev/null)

# 2. Every overlay file is declared.
declared="$(awk '/^[[:space:]]*-[[:space:]]*path:/ { sub(/^[[:space:]]*-[[:space:]]*path:[[:space:]]*/,""); print }' "$root/instance-manifest.yaml" 2>/dev/null)"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  p="${f#"$rel"/}"
  ok=0
  while IFS= read -r d; do
    d="${d%/}"
    [ -z "$d" ] && continue
    case "$p" in "$d"|"$d"/*) ok=1; break ;; esac
  done <<< "$declared"
  if [ "$ok" -eq 0 ]; then
    sct_block "the overlay tracks $p, which instance-manifest.yaml does not declare"
    sct_note "an inventory missing files is a list, not an inventory"
    findings=$((findings+1))
  fi
done < <(git -C "$overlay_root" ls-files "$rel" 2>/dev/null)

[ "$findings" -gt 0 ] && { printf 'check-boundary: %d finding(s)\n' "$findings" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-boundary: the toolkit and the overlay share no file, and the inventory is complete\n'
exit 0
