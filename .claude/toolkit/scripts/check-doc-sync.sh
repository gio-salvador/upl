#!/usr/bin/env bash
# Behaviour changes update their docs in the same pull request (Goal G14).
#
# The stamp ban was already gated; this half was convention, which means it held exactly as
# long as everyone remembered. A reference doc that rots is worse than a missing one, because
# it still reads as authoritative.
#
# Ownership comes from the parity mapping the docs standard already declares, not from a new
# table that would immediately need maintaining: `skills/<name>/SKILL.md` is described by
# `<docs>/skills/<name>.md`, and `agents/<name>.md` by `<docs>/agents/<name>.md`.
#
# Two strengths, because precision and coverage pull against each other here (TK-079):
#   BLOCKS when the source's frontmatter `name` or `description` changed and the reference doc
#   did not. The reference doc restates those directly, so they cannot disagree and both be
#   right. This is mechanical, and a false positive is close to impossible.
#   WARNS when the body changed substantively (more than --body-lines changed lines, default 5)
#   and the reference doc did not. A behaviour change usually looks like this, but so does a
#   rewritten example, and a gate cannot tell them apart. Reported, not decided.
#
# A typo fix touches neither, which is the point: a gate that fires on trivia gets disabled.
#
# Usage: check-doc-sync.sh [--quiet] [--range <git-range>] [--body-lines <n>]
# Exit 0 clean, 1 finding, 2 cannot check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; range=""; body_lines=5
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) quiet=1 ;;
    --range) range="${2:-}"; shift ;;
    --body-lines) body_lines="${2:-5}"; shift ;;
    *) printf 'check-doc-sync: unknown argument %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
root="$(sct_root)" || exit 2
cd "$root" || exit 2

if [ -z "$range" ]; then
  base="$(git config --get gitops.defaultbranch 2>/dev/null)"
  [ -z "$base" ] && for b in origin/main origin/master main master; do
    git rev-parse --verify -q "$b" >/dev/null 2>&1 && { base="$b"; break; }
  done
  if [ -z "$base" ]; then
    [ "$quiet" -eq 1 ] || printf 'check-doc-sync: no default branch to compare against; nothing to check\n'
    exit 0
  fi
  mb="$(git merge-base "$base" HEAD 2>/dev/null)" || {
    [ "$quiet" -eq 1 ] || printf 'check-doc-sync: no common ancestor with %s; nothing to check\n' "$base"
    exit 0
  }
  range="$mb..HEAD"
fi

changed="$(git diff --name-only "$range" -- 2>/dev/null)" || exit 2
if [ -z "$changed" ]; then
  [ "$quiet" -eq 1 ] || printf 'check-doc-sync: no changes in %s\n' "$range"
  exit 0
fi

# The docs root is the repository's to declare; the standard's default is `docs`.
# sct_resolve returns "value<TAB>provenance"; the value alone is the path.
docs_root="$(sct_resolve docs.root "$root" 2>/dev/null | cut -f1)"
if [ -z "$docs_root" ]; then
  # Falling back silently would make every pair unresolvable and the gate would pass with
  # nothing checked, which is the failure mode that looks most like success (TK-079).
  printf 'check-doc-sync: cannot resolve docs.root; refusing to check nothing\n' >&2
  exit 2
fi

blocks=0; warns=0
while IFS= read -r src; do
  [ -n "$src" ] || continue
  case "$src" in
    skills/*/SKILL.md) name="${src#skills/}"; name="${name%/SKILL.md}"; ref="$docs_root/skills/$name.md" ;;
    agents/*.md)       name="$(basename "$src" .md)";                   ref="$docs_root/agents/$name.md" ;;
    *) continue ;;
  esac
  # A source added or removed in this range is the parity gate's business, not this one's.
  [ -f "$src" ] && [ -f "$ref" ] || continue
  printf '%s\n' "$changed" | grep -qx "$ref" && continue

  # Did the identity the reference doc restates change?
  if git diff "$range" -- "$src" | grep -Eq '^[+-](name|description):'; then
    sct_block "$src changed its name or description; $ref did not change with it"
    sct_note "the reference doc restates them, so they cannot disagree and both be right"
    blocks=$((blocks+1))
    continue
  fi
  n="$(git diff --numstat "$range" -- "$src" | awk '{print $1+$2}')"
  if [ -n "$n" ] && [ "$n" -gt "$body_lines" ]; then
    sct_warn "$src changed by $n lines; $ref did not change with it"
    warns=$((warns+1))
  fi
done <<< "$changed"

if [ "$blocks" -gt 0 ]; then
  printf 'check-doc-sync: %d blocking finding(s), %d warning(s)\n' "$blocks" "$warns" >&2
  exit 1
fi
[ "$quiet" -eq 1 ] || printf 'check-doc-sync: docs moved with their sources (%d warning(s))\n' "$warns"
exit 0
