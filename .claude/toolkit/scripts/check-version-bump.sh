#!/usr/bin/env bash
#
# check-version-bump.sh - the VERSION file must agree with what the commits say.
#
# WHY THIS EXISTS. VERSION is hand-edited, so the bump is a judgement made once, by
# whoever happens to be cutting the release, against a range they may not have read.
# v0.6.12 was cut before #113 landed and nobody noticed until a consuming repository
# went looking for a fix that was merged and unreleased. A number chosen by hand is a
# number nobody can check.
#
# WHAT IT DERIVES. Conventional commits already encode the answer, and this repository
# already writes them:
#
#   a `!` after the type or scope, or a `BREAKING CHANGE:` footer   -> breaking
#   feat                                                            -> feature
#   anything else (fix, chore, docs, refactor, test, ci, ...)       -> patch
#
# HOW THAT MAPS, AND WHY 0.x IS NOT SPECIAL-CASED CARELESSLY. Semver says 0.y.z is
# unstable and anything may change. The convention every package manager actually
# implements for `^0.x` is that the MINOR position is the breaking slot, so a breaking
# change in 0.6.13 goes to 0.7.0, not 0.6.14. Once the project reaches 1.0 the ordinary
# mapping applies. Both are encoded below rather than left to the person cutting.
#
#   0.x:   breaking -> minor      feature -> patch      patch -> patch
#   >=1.0: breaking -> major      feature -> minor      patch -> patch
#
# WHEN IT IS SILENT. If VERSION still equals the newest tag there is no release in
# progress and nothing to judge, so it exits 0. It only speaks when someone has moved
# VERSION, which is exactly the moment the judgement is being made.
#
# ONLY A RELEASE MOVES VERSION. With --range, every commit in that range that changes VERSION
# must be a `chore(release)` commit, and --subject, when given, is the subject the range will
# land as (a pull request's title, which a squash merge uses). #137 set VERSION inside a feature
# pull request and #140 had to correct it; a number moved as a side effect of other work is a
# number nobody was looking at when it moved.
#
# PRINTING THE NEXT VERSION. --print-next prints `<version> <level>` for the commits since the
# newest tag reachable from --ref (default HEAD) and judges nothing; it exits 3 when there are no
# such commits. `sct release` takes the number from here, so the release and the gate cannot
# derive it two ways.
#
# Usage: bash scripts/check-version-bump.sh [--quiet] [--range <git-range>] [--subject <s>]
#        bash scripts/check-version-bump.sh --print-next [--ref <ref>]
# Exit 0 agrees, 1 disagrees, 2 cannot check, 3 nothing to release (--print-next only).

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

QUIET=0; RANGE=""; SUBJECT=""; HAVE_SUBJECT=0; PRINT_NEXT=0; REF=HEAD
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet)   QUIET=1 ;;
    --print-next) PRINT_NEXT=1 ;;
    --ref)     REF="${2:-}"; shift ;;
    --range)   RANGE="${2:-}"; shift ;;
    --subject) SUBJECT="${2:-}"; HAVE_SUBJECT=1; shift ;;
    *) echo "check-version-bump: unknown argument $1" >&2; exit 2 ;;
  esac
  shift
done
say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

[ -r VERSION ] || { echo "check-version-bump: no VERSION file at $ROOT" >&2; exit 2; }
current="$(tr -d '[:space:]' < VERSION)"

is_release() { grep -qE '^chore\(release\)!?: ' <<<"$1"; }

if [ -n "$RANGE" ]; then
  touched="$(git log --no-merges --format='%h %s' "$RANGE" -- VERSION 2>/dev/null)" || {
    echo "check-version-bump: cannot read the range $RANGE" >&2; exit 2; }
  offenders=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    is_release "${line#* }" || offenders="${offenders}  ${line}"$'\n'
  done <<<"$touched"
  if [ -n "$offenders" ]; then
    printf 'check-version-bump: VERSION moved outside a release commit in %s:\n%s' "$RANGE" "$offenders" >&2
    printf 'Only a `chore(release): <version>` commit changes VERSION. `sct release` writes one.\n' >&2
    exit 1
  fi
  if [ -n "$touched" ] && [ "$HAVE_SUBJECT" -eq 1 ] && ! is_release "$SUBJECT"; then
    printf 'check-version-bump: this change moves VERSION but will land as "%s".\n' "$SUBJECT" >&2
    printf 'A pull request that moves VERSION is titled `chore(release): <version>`.\n' >&2
    exit 1
  fi
fi

git rev-parse --verify --quiet "$REF^{commit}" >/dev/null || { echo "check-version-bump: no such ref $REF" >&2; exit 2; }
last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' "$REF" 2>/dev/null || true)"
if [ -z "$last_tag" ]; then
  [ "$PRINT_NEXT" -eq 1 ] && { echo "check-version-bump: no release tag reachable from $REF" >&2; exit 2; }
  say "check-version-bump: no release tag yet, nothing to derive from."
  exit 0
fi
last_ver="${last_tag#v}"

if [ "$PRINT_NEXT" -eq 0 ] && [ "$current" = "$last_ver" ]; then
  say "check-version-bump: VERSION ($current) still at the newest tag, no release in progress."
  exit 0
fi

# What the range actually contains. Read the range, not the branch: a pull request can
# land between the branch point and the tag, which is how this repository lost #115 from
# a release draft and #113 from a release entirely, one day apart.
range="${last_tag}..${REF}"
if [ "$PRINT_NEXT" -eq 1 ] && [ -z "$(git rev-list -n 1 "$range" 2>/dev/null)" ]; then
  exit 3
fi
level=patch
while IFS= read -r subject; do
  case "$subject" in
    *"!:"*)                     level=breaking; break ;;
    feat*|feat\(*)              [ "$level" = breaking ] || level=feature ;;
  esac
done < <(git log --format='%s' "$range" 2>/dev/null)

# A here-string, not `git log | grep -q`: under pipefail grep -q exits at the first match, git log
# dies of SIGPIPE on its next write, and the pipeline reports no match. On a range as long as
# v0.7.1..8b88d01 that hid #152's footer, and only its `!` subject caught the breaking change.
if grep -qE '^BREAKING[ -]CHANGE:' <<<"$(git log --format='%B' "$range" 2>/dev/null)"; then
  level=breaking
fi

IFS=. read -r maj min pat <<<"$last_ver"
if [ "${maj:-0}" -eq 0 ]; then
  case "$level" in
    breaking) expected="0.$((min + 1)).0" ;;
    *)        expected="0.${min}.$((pat + 1))" ;;
  esac
else
  case "$level" in
    breaking) expected="$((maj + 1)).0.0" ;;
    feature)  expected="${maj}.$((min + 1)).0" ;;
    *)        expected="${maj}.${min}.$((pat + 1))" ;;
  esac
fi

if [ "$PRINT_NEXT" -eq 1 ]; then
  printf '%s %s\n' "$expected" "$level"
  exit 0
fi

if [ "$current" = "$expected" ]; then
  say "check-version-bump: OK. $last_ver -> $current ($level change in $range)."
  exit 0
fi

cat >&2 <<EOF
check-version-bump: VERSION disagrees with the commits.

  newest tag   $last_tag
  range        $range
  range says   $level
  expected     $expected
  VERSION says $current

The range decides, not the branch. If $current is deliberate, say why in the release
entry; if the range is wrong, the branch probably needs rebasing onto the base it will
be tagged from.
EOF
exit 1
