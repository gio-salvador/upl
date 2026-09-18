#!/usr/bin/env bash
# Namespacing gate (Goal G33). Fleet tools carry the `sc-` prefix; project-local tools must not,
# so a repository's own tooling can never shadow a fleet tool of the same name.
# Usage: check-namespacing.sh [--root DIR]. Exit 0 clean, 1 finding.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
root="${2:-$(sct_root)}" || exit 2
findings=0
toolkit_home="$(sct_home)"

if [ "$root" = "$toolkit_home" ]; then
  # Inside the toolkit: every skill and agent must carry the prefix.
  for d in skills agents; do
    [ -d "$root/$d" ] || continue
    for n in "$root/$d"/*; do
      b="$(basename "$n" .md)"
      case "$b" in sc-*) ;; *) sct_block "fleet tool without the sc- prefix: $d/$(basename "$n")"; findings=$((findings+1)) ;; esac
    done
  done
else
  # Inside a consuming repository: project-local tools must not claim the fleet prefix.
  for d in .claude/skills .claude/agents; do
    [ -d "$root/$d" ] || continue
    for n in "$root/$d"/*; do
      b="$(basename "$n" .md)"
      case "$b" in sc-*) sct_block "project-local tool shadows the fleet prefix: $d/$(basename "$n")"; findings=$((findings+1)) ;; esac
    done
  done
fi
[ "$findings" -gt 0 ] && exit 1
exit 0
