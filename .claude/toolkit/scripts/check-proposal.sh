#!/usr/bin/env bash
# Efficiency proposals never buy themselves with quality (Goal G57).
#
# The observer's own instructions already forbid trading quality for speed. That was prose: a
# rule stated to the thing it constrains, checked by nobody. This gate reads what the observer
# actually wrote and holds it to the rule (TK-077).
#
# Two things it can decide mechanically, and one it deliberately cannot:
#   1. Shape. Every proposal validates against schemas/efficiency-proposal.schema.json, so a
#      proposal cannot omit the quality verdict it would rather not state.
#   2. The cross-field rule a schema cannot express: a proposal may be RECOMMENDED FOR ADOPTION
#      only if it declares itself quality-neutral or quality-positive. Recording a rejected
#      idea stays allowed and useful; recommending one does not.
#   3. Self-report contradiction. If the change text names one of the three shapes G57 puts out
#      of scope -- weakening a reviewer, dropping a grounding step, collapsing a loop's exit
#      condition -- while the verdict says neutral or positive, the two disagree and a human
#      settles it. This is a prompt for review, not a verdict on intent; it is reported as a
#      warning, because a gate that cannot read intent should not pretend it can.
#
# Usage: check-proposal.sh [--quiet] [--file <path>]. Exit 0 clean, 1 finding, 2 cannot check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; file=""
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) quiet=1 ;;
    --file) file="${2:-}"; shift ;;
    *) printf 'check-proposal: unknown argument %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
root="$(sct_root)" || exit 2
home="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -z "$file" ]; then
  # The tracker's location is the repository's to declare; there is no fleet-wide path.
  file="$(awk '/^[[:space:]]*output_path:/ { sub(/^[[:space:]]*output_path:[[:space:]]*/,""); gsub(/["'"'"']/,""); print; exit }' \
    "$root/.claude/efficiency-optimizer.yaml" 2>/dev/null)"
  [ -n "$file" ] && file="$root/$file"
fi
if [ -z "$file" ] || [ ! -r "$file" ]; then
  [ "$quiet" -eq 1 ] || printf 'check-proposal: no proposal tracker; nothing to check\n'
  exit 0
fi

python3 "$home/scripts/check-proposal.py" "$file" "$quiet"
