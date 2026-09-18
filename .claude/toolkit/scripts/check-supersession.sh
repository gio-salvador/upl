#!/usr/bin/env bash
# check-supersession.sh — the old copy that never went away.
#
# THE FAILURE THIS EXISTS FOR. A fix ships, and an older copy of the same file survives somewhere
# a lookup order can still reach. The lookup order picks the old one, the old one runs, and it
# reports success -- so the new code is correct, merged, and completely inert. This is not
# hypothetical: six repositories here each carried their own copy of a security guard, every copy
# superseded, every copy still winning, and nothing on the machine said a word. It was found by
# reading files, which is not a control.
#
# WHAT IT CHECKS. Within ONE repository, tracked TOOL files (executables and scripts, plus
# anything under a tool directory) that share a basename but DIFFER in content. That is the
# mechanical signature of a replacement whose incumbent was left behind: two things answering to
# the same name, and something upstream deciding silently between them.
#
# WHAT IT DOES NOT CHECK. Whether a vendored copy matches the version it pins -- `sct vendor
# --check` owns that, and pre-push runs it. The two are complementary: that one catches a copy
# that drifted from ITS pin, this one catches a second copy nobody remembered existed.
#
# Identical duplicates are NOT reported. A byte-identical copy cannot behave differently, so it
# is a tidiness question, not a correctness one, and a gate that reports it would be noise.
#
# Severity: WARN by default, because a shared basename is sometimes legitimate (two subprojects
# with their own `run.sh`). `--strict` makes it blocking, and CI runs strict.
#
# Per-repo allowlist `<root>/.claude/supersession-allow` (one `pattern  # justification` per
# line; a finding is suppressed when any of its paths contains the pattern).
#
# Usage: check-supersession.sh [--root DIR] [--strict] [--quiet]
# Exit:  0 clean (or only WARN), 1 blocking finding(s), 2 usage/environment error.
set -uo pipefail

root="" strict=0 quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    --strict) strict=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,31p' "$0"; exit 0 ;;
    *) echo "check-supersession: unknown arg '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$root" ] || root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$root" ] || [ ! -d "$root" ]; then
  echo "check-supersession: --root is not a directory" >&2; exit 2
fi

# Tool surfaces only. A duplicated `README.md` or a repeated content file is not a supersession
# question; a duplicated hook, script or library is exactly one.
# TOOL SURFACES, AND APPLICATION SOURCE IS NOT ONE. An early version listed `*.ts` and `*.mjs`
# among the extensions, which made every `index.ts` in a TypeScript project a finding: barrel
# files are the most duplicated filename in that ecosystem and nothing resolves BETWEEN them.
# It reported one on the first real repository it was pointed at. A gate whose findings a reader
# learns to scroll past has already stopped working, so the extensions are limited to shell and
# python -- the things that get copied and shadowed -- and a tool written in TypeScript is still
# covered when it lives in a tool directory, which is where a tool lives.
in_scope() {
  case "$1" in
    *.sh|*.zsh|*.bash|*.py) return 0 ;;
    hooks/*|scripts/*|gitops/*|bin/*|lib/*|.claude/hooks/*|.claude/scripts/*|.claude/toolkit/*) return 0 ;;
    *) return 1 ;;
  esac
}

allow=()
if [ -r "$root/.claude/supersession-allow" ]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] && allow+=("$line")
  done < "$root/.claude/supersession-allow"
fi
allowed() {
  local hay="$1" p
  for p in "${allow[@]:-}"; do
    [ -n "$p" ] && case "$hay" in *"$p"*) return 0 ;; esac
  done
  return 1
}

# Enumerate via git, never a filesystem walk: ignored files and submodule contents must not
# participate, and a build artefact duplicating a name is not a finding.
files=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  in_scope "$line" && files+=("$line")
done < <(git -C "$root" ls-files --cached --others --exclude-standard 2>/dev/null || true)

# Group by basename. bash 3.2 has no associative arrays, so sort a "basename<TAB>path" list and
# walk the runs.
findings=0
prev_base=""; group=()

report_group() {
  [ "${#group[@]}" -ge 2 ] || return 0
  # Distinct contents only: identical copies cannot diverge in behaviour.
  local hashes=() p h uniq=0
  for p in "${group[@]}"; do
    h="$( (shasum -a 256 "$root/$p" 2>/dev/null || sha256sum "$root/$p" 2>/dev/null) | awk '{print $1}')"
    hashes+=("$h")
  done
  uniq="$(printf '%s\n' "${hashes[@]}" | sort -u | grep -c . )"
  [ "$uniq" -ge 2 ] || return 0
  local joined; joined="$(printf '%s ' "${group[@]}")"
  allowed "$joined" && return 0
  findings=$((findings+1))
  if [ "$quiet" -ne 1 ]; then
    local sev="WARN"; [ "$strict" -eq 1 ] && sev="BLOCK"
    printf '%s  %s — %d copies, %d distinct, one name:\n' "$sev" "$prev_base" "${#group[@]}" "$uniq"
    local i=0
    for p in "${group[@]}"; do
      printf '        %s  (%s)\n' "$p" "$(printf '%s' "${hashes[$i]}" | cut -c1-8)"
      i=$((i+1))
    done
    printf '        which one runs is decided by a lookup order, not by this file. If one supersedes\n'
    printf '        the other, remove it; if both must exist, record why in .claude/supersession-allow.\n'
  fi
}

while IFS=$'\t' read -r base path; do
  [ -n "$base" ] || continue
  if [ "$base" != "$prev_base" ]; then
    report_group
    prev_base="$base"; group=()
  fi
  group+=("$path")
done < <(for f in "${files[@]:-}"; do [ -n "$f" ] && printf '%s\t%s\n' "${f##*/}" "$f"; done | sort)
report_group

[ "$quiet" -eq 1 ] || printf 'check-supersession: %d duplicated tool name(s) with divergent content (root %s)\n' "$findings" "$root"
if [ "$findings" -gt 0 ] && [ "$strict" -eq 1 ]; then exit 1; fi
exit 0
