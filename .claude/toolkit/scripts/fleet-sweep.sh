#!/usr/bin/env bash
# Fleet sweep (Goal G6, TK-008). The scheduled entry point.
#
# Walks the repository registry, reports coverage and staleness, and prepares one branch per
# stale repository. It NEVER merges and never pushes: autonomy belongs in discovery and
# preparation, not in the merge. A toolkit change reaching every repository unreviewed means one
# bad hook can block the whole fleet before anyone sees it.
#
# Reached as `sct sweep [--prepare]`, which is what a schedule should name: the tool, not this
# path. Running the file directly still works.
#
# Usage: fleet-sweep.sh [--prepare]   (--prepare creates branches; default is report-only)
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

# Read EVERY argument, and refuse the ones this does not understand. Testing only $1 against
# --prepare meant a typo, or a flag in second position, was discarded in silence: the sweep
# reported, prepared nothing, and exited 0, which is indistinguishable from a fleet with nothing
# to prepare. A scheduled job nobody watches must fail loudly or not at all.
prepare=0
while [ $# -gt 0 ]; do
  case "$1" in
    --prepare) prepare=1; shift ;;
    -h|--help) printf 'usage: fleet-sweep.sh [--prepare]\n'; exit 0 ;;
    *) sct_block "unknown argument '$1'"; sct_note "usage: fleet-sweep.sh [--prepare]"; exit 2 ;;
  esac
done
home="$(sct_home)"
reg="${CLAUDE_CONFIG_HOME:-$HOME/.claude}/config/gitops-tiers.json"

[ -r "$reg" ] || { sct_block "no repository registry at $reg"; exit 1; }
sct_need jq || exit 2

printf 'fleet sweep, toolkit %s\n' "$(sct_version)"

# The sweep reports on the fleet using whatever this checkout has. Scheduled, that checkout may
# be sitting on somebody's feature branch, and the report would then describe the fleet through
# unmerged code without saying so. Say so (TK-073).
sweep_branch="$(git -C "$home" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
sweep_default="$(git -C "$home" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
[ -n "$sweep_default" ] || sweep_default=main
if [ -n "$sweep_branch" ] && [ "$sweep_branch" != "$sweep_default" ]; then
  sct_warn "the toolkit checkout is on '$sweep_branch', not '$sweep_default'"
  sct_note "this report reflects that branch's code, which may be unmerged"
fi
printf '\n'
bash "$home/bin/sct" audit --all || true

[ "$prepare" -eq 0 ] && {
  printf '\nReport only. Re-run with `sct sweep --prepare` to create update branches.\n'
  exit 0
}

printf '\npreparing update branches\n'
prepared=0
while IFS= read -r repo; do
  repo="${repo/#\~/$HOME}"
  [ -d "$repo/.git" ] || continue
  have="$(sct_yaml_get "$repo/.claude/toolkit.lock" version)"
  [ -z "$have" ] && continue                      # not adopted: adoption is a human decision
  # Only a repository BEHIND A RELEASE is swept. One pinned to unreleased commits is not behind
  # anything an operator can act on, and sweeping it would open a pull request per repository
  # every time anything merged (TK-072).
  case "$(sct_pin_state "$have")" in behind*) ;; *) continue ;; esac

  name="$(basename "$repo")"
  if [ -n "$(git -C "$repo" status --porcelain)" ]; then
    sct_warn "$name: working tree is dirty, skipped"
    sct_note "a sweep must never commit somebody else's in-progress work"
    continue
  fi
  branch="chore/toolkit-$(sct_version)"
  git -C "$repo" switch -q -c "$branch" 2>/dev/null || { sct_warn "$name: branch $branch exists, skipped"; continue; }
  ( cd "$repo" && bash "$home/bin/sct" vendor >/dev/null ) || { sct_warn "$name: vendor failed"; continue; }

  # The repository's own gate decides whether this upgrade is safe for it.
  check="$(git -C "$repo" config --get gitops.repocheck || true)"
  if [ -n "$check" ]; then
    if ( cd "$repo" && eval "$check" >/dev/null 2>&1 ); then verdict="gate passed"; else verdict="GATE FAILED"; fi
  else
    verdict="no gate configured"
  fi
  git -C "$repo" add -A >/dev/null
  git -C "$repo" commit -q -m "chore(toolkit): update to $(sct_version)

Prepared by the fleet sweep. $verdict.
Changelog entries between $have and $(sct_version) are in the toolkit repository." || true
  printf '  %-40s %s -> %s  (%s)\n' "$name" "$have" "$(sct_version)" "$verdict"
  prepared=$((prepared+1))
done < <(jq -r '.repos | keys[]' "$reg" 2>/dev/null)

printf '\n%d branch(es) prepared locally. Nothing pushed, nothing merged.\n' "$prepared"
printf 'Review each, then open its pull request.\n'
