#!/usr/bin/env bash
# The core gates work with no network (Goal G45).
#
# A gate that reaches the network is a gate that fails on a train, in an air-gapped runner, or
# whenever a third party is down. Then it gets skipped "just this once", and a skipped gate is
# no gate. So this asserts statically that no gate invokes a network client.
#
# It is a source check, not a runtime one, because a gate that only *sometimes* reaches out
# would pass a single offline run and still fail later. The identity guard is the sole exception
# and declares it: it asks the forge who you are, and degrades rather than blocking when it
# cannot (TK-041).
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
cd "$root" || exit 2

allowed_network() { case "$1" in hooks/identity-guard.sh) return 0 ;; *) return 1 ;; esac; }

findings=0
while IFS= read -r hit; do
  f="${hit%%:*}"
  allowed_network "$f" && continue
  sct_block "a gate reaches the network: $hit"
  sct_note "gates must work offline; a gate that fails on a train gets skipped, and a skipped gate is none"
  findings=$((findings+1))
done < <(git grep -nE '(^|[;&|( ])(curl|wget|nc|ping)[[:space:]]' -- 'scripts/check-*.sh' 'gitops/lib/*.sh' 'gitops/hooks/*' 2>/dev/null)

[ "$findings" -gt 0 ] && { printf 'check-offline: %d gate(s) reach the network\n' "$findings" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-offline: no gate reaches the network\n'
exit 0
