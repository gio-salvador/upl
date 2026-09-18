#!/usr/bin/env bash
# Generated state is marked as generated (Goal G39).
#
# The profile separates state a tool WRITES from state a person AUTHORS. That separation only
# helps if a person opening the file can tell which they are looking at: a generated file with no
# marker gets hand-edited, and the next regeneration silently discards the edit. The person who
# lost the work usually concludes the tool is unreliable, which is the wrong lesson.
#
# So every path the profile declares under `state.generated` must say so in its first few lines.
# Nothing here inspects content: the marker is the contract.
#
# Usage: check-generated-state.sh [--quiet]. Exit 0 clean, 1 finding.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
prof="$root/.claude/profile.yaml"
[ -r "$prof" ] || { [ "$quiet" -eq 1 ] || printf 'check-generated-state: no profile\n'; exit 0; }

findings=0; checked=0
while IFS= read -r pth; do
  pth="$(printf '%s' "$pth" | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//')"
  [ -n "$pth" ] || continue
  [ -e "$root/$pth" ] || continue          # absence is the audit's finding, not this one's
  checked=$((checked+1))
  if head -8 "$root/$pth" 2>/dev/null | grep -qiE "generated|do not edit|never hand-edit|append-only"; then
    continue
  fi
  sct_block "$pth is declared generated but does not say so in its first lines"
  sct_note "a generated file with no marker gets hand-edited, and the next regeneration discards it"
  findings=$((findings+1))
done < <(awk '/^state:/{s=1;next} s&&/^[a-z]/{exit}
              s&&/^[[:space:]]+generated:/{f=1;next} s&&/^[[:space:]]+[a-z_]+:/{f=0}
              s&&f&&/^[[:space:]]+-/{print}' "$prof" 2>/dev/null)

[ "$findings" -gt 0 ] && { printf 'check-generated-state: %d unmarked generated file(s)\n' "$findings" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-generated-state: %d generated file(s), all marked\n' "$checked"
exit 0
