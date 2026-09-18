#!/usr/bin/env bash
# Context economy as a measurable constraint (Goal G60).
#
# Every skill and agent file is loaded into a model's context, most of them on many runs. A file
# that grows without anyone noticing is a standing tax paid on every invocation, and unlike a slow
# script nothing surfaces it: the cost is spread across every future run rather than one visible
# moment.
#
# So the size is measured and budgeted. This is a PROXY, and an honest one: a large file is not
# automatically wasteful, and a small one can still load everything it touches. What it reliably
# catches is drift, a file that doubled while nobody was looking.
#
# STAGED like every other host-facing gate (TK-058): blocking in the toolkit and in a repository
# that declares a budget, advisory in one that has declared nothing.
#
# Budget: profile `efficiency.context_budget_lines`, default 400.
# Usage: check-context-budget.sh [--quiet]. Exit 0 clean or advisory, 1 over budget.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
prof="$root/.claude/profile.yaml"

budget="$(sct_yaml_get "$prof" efficiency.context_budget_lines 2>/dev/null)"
declared=1; [ -n "$budget" ] || { budget=400; declared=0; }
blocking=1
[ "$root" = "$(sct_home)" ] || [ "$declared" = "1" ] || blocking=0

over=0; total=0; count=0
while IFS= read -r f; do
  [ -e "$root/$f" ] || continue
  n="$(wc -l < "$root/$f" | tr -d ' ')"
  total=$((total+n)); count=$((count+1))
  if [ "$n" -gt "$budget" ]; then
    sct_warn "$f is $n lines, over the $budget-line context budget"
    over=$((over+1))
  fi
done < <(sct_tracked "$root" | grep -E '^(skills/.*/SKILL\.md|agents/.*\.md)$' || true)

[ "$count" -eq 0 ] && { [ "$quiet" -eq 1 ] || printf 'check-context-budget: no skills or agents here\n'; exit 0; }

if [ "$over" -gt 0 ]; then
  sct_note "these are read on every run that loads them; a file that grew is a tax nobody chose to pay"
  if [ "$blocking" -eq 1 ]; then
    printf 'check-context-budget: %d file(s) over budget\n' "$over" >&2
    exit 1
  fi
  printf 'check-context-budget: %d over budget (advisory: set efficiency.context_budget_lines to enforce)\n' "$over" >&2
  exit 0
fi
[ "$quiet" -eq 1 ] || printf 'check-context-budget: %d file(s), %d lines total, largest within the %d-line budget\n' "$count" "$total" "$budget"
exit 0
