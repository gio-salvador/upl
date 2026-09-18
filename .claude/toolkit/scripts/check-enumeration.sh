#!/usr/bin/env bash
# Enumeration gate (Goal G31). Tools enumerate repository content through `git ls-files`, never a
# filesystem walk: git already applies .gitignore, so every excluded path is excluded without
# this code needing to know it exists.
#
# Advisory by default because a `find` over a build directory or a temp path is legitimate.
# --block turns findings into failures for repositories that have finished migrating.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
block=0; [ "${1:-}" = "--block" ] && block=1
root="$(sct_root)" || exit 2
findings=0
while IFS= read -r hit; do
  f="${hit%%:*}"
  case "$f" in scripts/check-enumeration.sh) continue ;; esac
  sct_warn "filesystem walk over repository content: $f (prefer git ls-files)"
  findings=$((findings+1))
done < <(git -C "$root" grep -n -E '(^|[^a-z-])find[[:space:]]+("?\$(root|ROOT)"?|\.)[[:space:]]' -- 'scripts/*' 'lib/*' 'bin/*' 'hooks/*' 'gitops/*' 2>/dev/null)
[ "$findings" -gt 0 ] && [ "$block" -eq 1 ] && exit 1
exit 0
