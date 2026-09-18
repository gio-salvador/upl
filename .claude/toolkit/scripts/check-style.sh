#!/usr/bin/env bash
# Style gate for prose (Goal G7; TK-025).
#
# BLOCKING on paths listed in config/style-blocking-paths.txt: em dashes and en dashes.
# ADVISORY everywhere else, until the inherited corpus is migrated.
#
# WHY STAGED. The rule itself is absolute, but 1206 occurrences arrived with the extracted
# toolkit. A gate that fails on day one against inherited content does not get adopted, it gets
# bypassed, and then it protects nothing. New material is held to the rule immediately; the
# backlog is visible, counted, and flips to blocking when it reaches zero.
#
# Usage: check-style.sh [--all-blocking] [--quiet]
# Exit:  0 clean or advisory-only, 1 blocking finding.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

all_blocking=0; quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --all-blocking) all_blocking=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "check-style: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

root="$(sct_root)" || exit 2
cd "$root" || exit 2
# The blocking list belongs to the REPOSITORY UNDER CHECK, not to the toolkit. The toolkit's
# own list records the toolkit's migration state; applying it elsewhere would fail every
# adopting repository on day one against paths it never agreed to, which is precisely how a
# staged gate stops being staged and starts being bypassed (TK-025).
#
# A repository with no list of its own gets an all-advisory run: the backlog is counted and
# visible, and nothing blocks until that repository declares what it has migrated.
list="$root/.claude/style-blocking-paths.txt"
[ -r "$list" ] || list="$(sct_home)/config/style-blocking-paths.txt"
[ "$root" = "$(sct_home)" ] || [ -r "$root/.claude/style-blocking-paths.txt" ] || list=""

# Load the prefix list ONCE. Reading it per finding turned an O(findings) check into
# O(findings x prefixes) with a file read each time, and a repository with a few thousand
# occurrences took longer than anyone would wait, so the gate simply never got run there.
prefixes=()
if [ -r "$list" ]; then
  while IFS= read -r pre; do
    pre="${pre%%#*}"; pre="$(printf '%s' "$pre" | tr -d '[:space:]')"
    [ -n "$pre" ] && prefixes+=("$pre")
  done < "$list"
fi

is_blocking() {
  [ "$all_blocking" -eq 1 ] && return 0
  local pre
  for pre in ${prefixes[@]+"${prefixes[@]}"}; do
    case "$1" in "$pre"*) return 0 ;; esac
  done
  return 1
}

blocks=0; advisory=0
while IFS= read -r hit; do
  f="${hit%%:*}"
  case "$f" in config/regulatory/*) continue ;;   # mirrored primary texts are quoted, not authored
  esac
  if is_blocking "$f"; then
    sct_block "long dash in $hit"
    blocks=$((blocks+1))
  else
    advisory=$((advisory+1))
  fi
done < <(git grep -n -e '—' -e '–' -- '*.md' 2>/dev/null)

if [ "$advisory" -gt 0 ] && [ "$quiet" -eq 0 ]; then
  sct_warn "$advisory long dash(es) in the unmigrated corpus (advisory; see TK-025)"
fi
[ "$blocks" -gt 0 ] && { printf 'check-style: %d blocking finding(s)\n' "$blocks" >&2; exit 1; }
exit 0
