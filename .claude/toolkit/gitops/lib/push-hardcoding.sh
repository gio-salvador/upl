#!/usr/bin/env bash
# push-hardcoding.sh - the pre-push hook's hardcoding and secret-placement step.
#
# WHY THIS IS A FILE AND NOT LINES IN THE HOOK. The linter's header said for months that the
# pre-push hook called it, and the hook never did. A step that lives inside the hook can only be
# proved by running the hook end to end, which needs signing and a remote, so it gets asserted by
# searching for a string instead (TK-109). This one the suite runs.
#
# WHAT IT JUDGES. For each pushed range, what the BRANCH adds: the diff from the merge-base with
# the remote default branch to the range's tip. After a rebase the old-tip..new-tip range sweeps
# in the default branch's own commits, and judged literally their lines would count as this
# branch's. Two consequences, both accepted: a feature branch is judged on everything it adds
# each time it is pushed, and a stale local copy of the remote default branch gives an old base
# (fetch first). With no default branch to compare against, the range's own base is used; with
# no base at all (a first push to an empty remote) it is a whole-tree run.
#
# THE MODE decides what refuses the push. It is the git config key `gitops.hardcoding`, which
# `setup-gitops.sh` copies from the tier registry.
#
#   mode       secret finding   introduced path finding   inherited path finding   linter flag
#   warn       reported         reported                  reported                 none
#   block      refuses          refuses                   reported                 --paths-block-new
#   block-all  refuses          refuses                   refuses                  --paths-block
#
# Unset means DEFAULT_MODE below. It is warn for the release that announces the promotion and
# becomes block in the change that follows it (TK-120). An unrecognised value is reported and
# treated as warn.
#
# The linter is the one BESIDE THIS FILE, never a vendored copy. The hook git runs is the toolkit
# checkout, and a consuming repository's vendored linter is older until it re-vendors: looked up
# vendored-first, it would reject a flag it has never heard of in exactly the repositories this
# step is for (TK-119).
#
# Silent when the linter reports nothing. A linter that cannot run is reported as DEGRADED and
# is fatal only under GITOPS_STRICT=1, the same contract the vendored-drift step has.
#
# Usage: push-hardcoding.sh --root DIR [--mode warn|block|block-all] RANGE...
# Exit:  0 the push may proceed, 1 refused.
set -uo pipefail

DEFAULT_MODE="warn"

root="" mode="" ranges=()
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    --mode) mode="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,38p' "$0"; exit 0 ;;
    *) ranges+=("$1"); shift ;;
  esac
done
say() { printf 'pre-push: hardcoding: %s\n' "$*" >&2; }
strict_or_pass() { # a check that could not run: fatal only under strict
  [ "${GITOPS_STRICT:-0}" = "1" ] && { say "strict mode: a check that cannot run is a failure."; exit 1; }
  exit 0
}

[ -n "$root" ] && [ -d "$root" ] || { say "no repository root given - check DEGRADED TO OFF."; strict_or_pass; }

src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  d="$(cd -P "$(dirname "$src")" && pwd)"; src="$(readlink "$src")"
  case "$src" in /*) ;; *) src="$d/$src" ;; esac
done
here="$(cd -P "$(dirname "$src")" && pwd)"
linter="$here/check-hardcoding.sh"
[ -r "$linter" ] || { say "the linter is not beside this step ($linter) - check DEGRADED TO OFF (not skipped silently)."; strict_or_pass; }

[ -n "$mode" ] || mode="$(git -C "$root" config --get gitops.hardcoding 2>/dev/null || true)"
[ -n "$mode" ] || mode="$DEFAULT_MODE"
flag=()
case "$mode" in
  warn) ;;
  block) flag=(--paths-block-new) ;;
  block-all) flag=(--paths-block) ;;
  *) say "gitops.hardcoding is '$mode', which is not warn, block or block-all - treating it as warn."
     [ "${GITOPS_STRICT:-0}" = "1" ] && { say "strict mode: an unrecognised mode is a failure."; exit 1; }
     mode="warn" ;;
esac

# The remote default branch, by the same three candidates the hook tries.
defref="$(git -C "$root" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || true)"
[ -n "$defref" ] || { git -C "$root" rev-parse --verify --quiet origin/main >/dev/null 2>&1 && defref="origin/main"; }
[ -n "$defref" ] || { git -C "$root" rev-parse --verify --quiet origin/master >/dev/null 2>&1 && defref="origin/master"; }

[ "${#ranges[@]}" -gt 0 ] || ranges=("HEAD")
refused=0
for r in "${ranges[@]}"; do
  case "$r" in *..*) tip="${r#*..}"; own_base="${r%%..*}" ;; *) tip="$r"; own_base="" ;; esac
  base=""
  [ -n "$defref" ] && base="$(git -C "$root" merge-base "$tip" "$defref" 2>/dev/null || true)"
  [ -n "$base" ] || base="$own_base"

  args=(--root "$root")
  [ -n "$base" ] && args+=(--range "$base..$tip")
  rc=0
  out="$(bash "$linter" "${args[@]}" ${flag[@]+"${flag[@]}"} 2>&1)" || rc=$?
  case "$rc" in
    0) # Silent when clean: the count line alone is not a finding.
       grep -Eq '^check-hardcoding: 0 block, 0 warn' <<<"$out" || printf '%s\n' "$out" >&2 ;;
    1) printf '%s\n' "$out" >&2
       if [ "$mode" = "warn" ]; then
         say "the finding(s) marked BLOCK would refuse this push under gitops.hardcoding=block. Reported only: the mode is warn."
       else
         refused=1
       fi ;;
    *) printf '%s\n' "$out" >&2
       say "the linter could not run (exit $rc) - check DEGRADED TO OFF (not skipped silently)."
       strict_or_pass ;;
  esac
done

if [ "$refused" -ne 0 ]; then
  say "refused (gitops.hardcoding=$mode). Move the value into the path registry, a declared variable or sc-secret,"
  say "or record a justified exception in .claude/hardcoding-allow in the same push. Emergency: GITOPS_ALLOW_HARDCODE=1."
  [ -n "$defref" ] && say "a line you did not write? The base is the merge-base with $defref: fetch, and rebase if it moved."
  exit 1
fi
exit 0
