#!/usr/bin/env bash
# Decision ids are unique, and every id the summary cites exists (TK-091).
#
# Ids are allocated from the next free number on the default branch, so two branches in flight
# allocate the same one and neither can see the other. That is a property of the allocator, not a
# mistake anybody makes, and it stays invisible until the branches meet: the merge succeeds, both
# sections land, and the log now holds one id meaning two different decisions.
#
# It happened. Four ids arrived on one branch that the default branch already used for other
# decisions, and the ambiguity went live in a single tree, with two files citing the same id for
# unrelated reasons, before a person noticed. Nothing mechanical was looking.
#
# So this gate fails the merge that creates the duplicate, which is the last moment the repair is
# free: an unlanded id can be renumbered because nothing outside its branch can cite it, and a
# landed one cannot.
#
# Usage: check-decision-ids.sh [--quiet]. Exit 0 clean, 1 finding, 2 cannot run.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
log="${SCT_DECISION_LOG:-docs/decisions/log.md}"

# A repository with no decision log is a zero set, not an error.
[ -r "$root/$log" ] || { [ "$quiet" -eq 1 ] || printf 'check-decision-ids: no decision log at %s\n' "$log"; exit 0; }

# The id is what matters, not the punctuation after it: real headings in this log use both
# `## TK-076,` and `## TK-077.`, and a regex that assumed one silently skipped the other.
ids()  { grep -oE '^## TK-[0-9]+' "$root/$log" | sed -E 's/^## //'; }
rows() { grep -oE '^\| (TK-[0-9]+) \|' "$root/$log" | sed -E 's/^\| //; s/ \|$//'; }

findings=0

while IFS= read -r id; do
  [ -n "$id" ] || continue
  sct_block "$log: $id is used by more than one decision"
  sct_note "reconcile against the default branch: its ids win, this branch renumbers (TK-091)"
  findings=$((findings+1))
done < <(ids | sort | uniq -d)

while IFS= read -r id; do
  [ -n "$id" ] || continue
  sct_block "$log: the summary table lists $id more than once"
  findings=$((findings+1))
done < <(rows | sort | uniq -d)

while IFS= read -r id; do
  [ -n "$id" ] || continue
  sct_block "$log: the summary table cites $id, which has no decision section"
  sct_note "a citable id with nothing behind it is worse than an absent row"
  findings=$((findings+1))
done < <(comm -23 <(rows | sort -u) <(ids | sort -u))

[ "$findings" -gt 0 ] && { printf 'check-decision-ids: %d finding(s)\n' "$findings" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-decision-ids: %d decision(s), ids unique and every cited id exists\n' "$(ids | wc -l | tr -d ' ')"
exit 0
