#!/usr/bin/env bash
# Plan structure gate: a plan states what it is FOR, and how to tell it worked.
#
# THE FAILURE THIS EXISTS FOR. A plan says what will be built and in what order, is executed
# faithfully, and afterwards nobody can say whether it was worth doing, or whether it was applied
# CORRECTLY rather than merely applied. Both questions get answered before the work by the person
# who wanted it, or they get answered afterwards by whoever is disappointed.
#
# WHAT IT REQUIRES. Two sections in every plan:
#   Goals            - what the plan is for, traceable to something the repository already values
#   Success criteria - falsifiable statements, with a command wherever one exists
#
# WHY STAGED, AND THE FLIP CONDITION. Three plans predate this rule and carry neither section. A
# gate that fails on day one against inherited content does not get adopted, it gets bypassed, and
# then it protects nothing. That reasoning is TK-025's, and this follows it deliberately rather
# than inventing a fourth way to stage a gate. So: a plan with NEITHER section is counted and
# reported, not blocked. A plan with exactly ONE of the two BLOCKS, because that is not inherited
# content, it is a plan written under this rule that stopped halfway. When the backlog reaches
# zero the default flips to blocking and this paragraph goes.
#
# The blocking enforcement people actually feel is the sc-plan-review lens, which treats an absent
# section as a blocker at review time. This gate is the cheap mechanical backstop, so a plan
# cannot reach the default branch unexamined merely because nobody ran the review.
#
# Usage: check-plan-structure.sh [--root DIR] [--strict] [--quiet]
# Exit:  0 clean or advisory-only, 1 blocking finding, 2 environment error.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

strict=0; quiet=0; root=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    --strict) strict=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "check-plan-structure: unknown arg '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$root" ] || root="$(sct_root)" || exit 2
cd "$root" || exit 2

# The plan directory is the repository's to declare; the default matches the docs standard.
dir="${SCT_PLANS_DIR:-docs/plans}"
[ -d "$dir" ] || { [ "$quiet" -eq 1 ] || printf 'check-plan-structure: no %s directory\n' "$dir"; exit 0; }

blocks=0; backlog=0; checked=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  checked=$((checked+1))
  g=0; c=0
  grep -qiE '^## +Goals *$' "$f" && g=1
  grep -qiE '^## +Success criteria *$' "$f" && c=1
  [ "$g" -eq 1 ] && [ "$c" -eq 1 ] && continue
  if [ "$g" -eq 0 ] && [ "$c" -eq 0 ]; then
    backlog=$((backlog+1))
    [ "$quiet" -eq 1 ] || printf 'warn   %s: no Goals and no Success criteria (inherited backlog)\n' "$f" >&2
    [ "$strict" -eq 1 ] && blocks=$((blocks+1))
    continue
  fi
  # Exactly one of the two: written under this rule, and stopped halfway.
  blocks=$((blocks+1))
  missing="Goals"; [ "$g" -eq 1 ] && missing="Success criteria"
  printf 'BLOCK  %s: has one of the two required sections but not the other (missing: %s)\n' "$f" "$missing" >&2
done < <(git -C "$root" ls-files --cached --others --exclude-standard -- "$dir/*.md" 2>/dev/null || true)

if [ "$blocks" -gt 0 ]; then
  printf 'check-plan-structure: %d blocking finding(s) of %d plan(s)\n' "$blocks" "$checked" >&2
  exit 1
fi
[ "$quiet" -eq 1 ] || printf 'check-plan-structure: %d plan(s), %d in the inherited backlog (advisory; flips to blocking at zero)\n' "$checked" "$backlog"
exit 0
