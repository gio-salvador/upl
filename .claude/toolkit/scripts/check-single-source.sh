#!/usr/bin/env bash
# Single source of truth for a repository's own facts (Goal G17).
#
# The profile exists so a repository states its facts ONCE and skill manifests inherit them
# (TK-009). Nothing stopped a manifest restating a fact the profile already owns, which is how
# six manifests in one repository came to repeat the same values and drift apart.
#
# So: a key the profile declares must not be re-declared in a skill manifest with a DIFFERENT
# value. Repeating the same value is redundant but harmless and reported as such; contradicting
# it is a finding, because two answers to one question is the failure the profile prevents.
#
# Usage: check-single-source.sh [--quiet]. Exit 0 clean, 1 contradiction.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
prof="$root/.claude/profile.yaml"
[ -r "$prof" ] || { [ "$quiet" -eq 1 ] || printf 'check-single-source: no profile, nothing owns anything yet\n'; exit 0; }

# The facts the profile owns and a manifest might restate. Deliberately a short list of the
# values that actually recur, not every key: a check that flags coincidence teaches people to
# ignore it.
owned="surface voice persona tier default_branch"

contradictions=0; echoes=0
for key in $owned; do
  pval="$(grep -E "^[[:space:]]*$key:" "$prof" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')"
  [ -n "$pval" ] || continue
  for m in "$root"/.claude/*.yaml; do
    [ -e "$m" ] || continue
    case "$(basename "$m")" in profile.yaml|profile.local.yaml|toolkit.lock) continue ;; esac
    mval="$(grep -E "^[[:space:]]*$key:" "$m" | head -1 | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')"
    [ -n "$mval" ] || continue
    if [ "$mval" = "$pval" ]; then
      sct_note "${m#"$root"/} repeats $key from the profile (same value: redundant, not wrong)"
      echoes=$((echoes+1))
    else
      sct_block "${m#"$root"/} sets $key: $mval, but the profile says $pval"
      sct_note "two answers to one question; the profile owns it, or the profile is wrong"
      contradictions=$((contradictions+1))
    fi
  done
done

[ "$contradictions" -gt 0 ] && { printf 'check-single-source: %d contradiction(s)\n' "$contradictions" >&2; exit 1; }
[ "$quiet" -eq 1 ] || printf 'check-single-source: no manifest contradicts the profile (%d harmless repeat(s))\n' "$echoes"
exit 0
