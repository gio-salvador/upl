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
# Usage: bash scripts/check-version-bump.sh [--quiet]

set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1
say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

[ -r VERSION ] || { echo "check-version-bump: no VERSION file at $ROOT" >&2; exit 2; }
current="$(tr -d '[:space:]' < VERSION)"

last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null || true)"
if [ -z "$last_tag" ]; then
  say "check-version-bump: no release tag yet, nothing to derive from."
  exit 0
fi
last_ver="${last_tag#v}"

if [ "$current" = "$last_ver" ]; then
  say "check-version-bump: VERSION ($current) still at the newest tag, no release in progress."
  exit 0
fi

# What the range actually contains. Read the range, not the branch: a pull request can
# land between the branch point and the tag, which is how this repository lost #115 from
# a release draft and #113 from a release entirely, one day apart.
range="${last_tag}..HEAD"
level=patch
while IFS= read -r subject; do
  case "$subject" in
    *"!:"*)                     level=breaking; break ;;
    feat*|feat\(*)              [ "$level" = breaking ] || level=feature ;;
  esac
done < <(git log --format='%s' "$range" 2>/dev/null)

if git log --format='%B' "$range" 2>/dev/null | grep -qE '^BREAKING[ -]CHANGE:'; then
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
