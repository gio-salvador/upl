#!/usr/bin/env bash
# release.sh - cut a release whose number nobody chooses (Goal G47).
#
# WHY THIS EXISTS. Every release before this was a person editing VERSION, editing the
# changelog, merging, and remembering to tag, and each step was skipped at least once. #136 and
# #137 moved VERSION inside feature pull requests and #140 corrected it; 0.7.2 was written and
# never tagged; on 2026-09-03 a sweep vendored an untagged checkout into four repositories
# because VERSION led the tag. Here the number comes from the commits, by the same code the gate
# runs, the release is one commit of its own, and the tag goes on that commit and nowhere else.
#
# TWO HALVES, because a merge sits between them and a merge is a person's decision:
#
#   sct release          Prepare. Branch `chore/release-<v>` off the default branch, write <v> to
#                        VERSION, head the Unreleased notes with `### <v> - <date>`, and commit
#                        `chore(release): <v>`. Pushes nothing: open the pull request with
#                        sc-open-pr, as for any other change.
#   sct release --tag    After that pull request merges. Sign `v<v>` on the commit that set
#                        VERSION on the default branch (not its head, which may have moved on:
#                        a tag on the head would ship commits the notes do not describe), verify
#                        the signature, and push that one tag.
#
# THE NEWEST RELEASE IS THE REMOTE'S. A tag that exists only in this checkout is not a release
# (the v0.7.0 entry in docs/plans/inherited-debt.md), so both halves read the remote's tag list
# and refuse when a local release tag is missing from it.
#
#   sct release --status Is a release owed? Read-only and offline, so CI can run it on every push
#                        (TK-127). --due-days <n> sets when due becomes overdue (default 7),
#                        --annotate adds a GitHub warning line, --strict exits 1 when overdue.
#
# Usage: sct release [--tag | --status [--due-days <n>] [--annotate] [--strict]]
#                    [--remote <name>] [--no-push]
# Exit 0 done or nothing to do, 1 refused (or overdue under --strict), 2 cannot run.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

mode=prepare; remote=origin; push=1; due_days=7; annotate=0; strict=0
usage_line="usage: sct release [--tag | --status [--due-days <n>] [--annotate] [--strict]] [--remote <name>] [--no-push]"
while [ $# -gt 0 ]; do
  case "$1" in
    --tag)      mode=tag ;;
    --status)   mode=status ;;
    --due-days) due_days="${2:-}"; shift
                case "$due_days" in ''|*[!0-9]*) sct_block "--due-days takes a whole number of days"; exit 2 ;; esac ;;
    --annotate) annotate=1 ;;
    --strict)   strict=1 ;;
    --remote)   remote="${2:-}"; shift ;;
    --no-push)  push=0 ;;
    -h|--help)  awk 'NR>1 && /^#/ {sub(/^# ?/, ""); print; next} NR>1 {exit}' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) sct_block "unknown argument '$1'"; sct_note "$usage_line"; exit 2 ;;
  esac
  shift
done

root="$(sct_root)" || exit 2
cd "$root" || exit 2
for f in VERSION CHANGELOG.md scripts/check-version-bump.sh; do
  [ -f "$f" ] || { sct_block "no $f at $root"; sct_note "sct release cuts releases of a repository that carries VERSION, CHANGELOG.md and the version gate"; exit 2; }
done
# ---- --status: is a release due? Read-only and offline, so CI can run it on every push.
#
# WHEN A RELEASE IS DUE (TK-127). A release is due as soon as the default branch carries a change
# a consuming repository would run differently: a feat, a fix, a perf, a refactor, a revert, a
# build change, or anything breaking. Documentation, tests, CI and plan-routing commits change
# nothing that ships, so they never make a release due on their own. It is OVERDUE when the
# oldest such commit is older than --due-days (default 7), and at once when VERSION already names
# a release that has no tag: that release was reviewed and merged, and only the tag is missing.
# Advisory by design (docs/deprecation.md): it warns, and exits 0, unless --strict is passed.
if [ "$mode" = status ]; then
  ref=HEAD
  newest="$(git describe --tags --abbrev=0 --match 'v[0-9]*' "$ref" 2>/dev/null || true)"
  cur="$(tr -d '[:space:]' < VERSION)"
  verdict=ok; reason=""
  if [ -z "$newest" ]; then
    printf 'no release tag yet; VERSION reads %s\n' "$cur"
    exit 0
  fi
  if [ "$cur" != "${newest#v}" ]; then
    verdict=overdue
    reason="VERSION reads $cur and v$cur is not tagged: the release is merged; run sct release --tag"
  fi
  shipped=0; oldest=""; now="$(date +%s)"
  while IFS=' ' read -r ts subject; do
    [ -n "$ts" ] || continue
    case "$subject" in
      *'!:'*|feat*|fix*|perf*|refactor*|revert*|build*) ;;
      *) continue ;;
    esac
    shipped=$((shipped+1)); oldest="$ts"
  done < <(git log --no-merges --format='%ct %s' "$newest..$ref" 2>/dev/null)
  if grep -qE '^BREAKING[ -]CHANGE:' <<<"$(git log --no-merges --format='%B' "$newest..$ref" 2>/dev/null)"; then
    [ "$shipped" -gt 0 ] || { shipped=1; oldest="$(git log -1 --format=%ct "$ref")"; }
  fi
  total="$(git rev-list --no-merges --count "$newest..$ref" 2>/dev/null || echo 0)"
  printf 'newest release %s; %s commit(s) since, %s of them shipped code\n' "$newest" "$total" "$shipped"
  if [ "$verdict" = ok ] && [ "$shipped" -gt 0 ]; then
    next_out="$(bash scripts/check-version-bump.sh --print-next --ref "$ref" 2>/dev/null || true)"
    age_days=$(( (now - oldest) / 86400 ))
    if [ "$age_days" -ge "$due_days" ]; then
      verdict=overdue
      reason="${next_out%% *} is due: the oldest unreleased change is ${age_days} day(s) old (limit ${due_days})"
    else
      verdict=due
      reason="${next_out%% *} is due (${next_out#* } change); the oldest unreleased change is ${age_days} day(s) old"
    fi
  fi
  case "$verdict" in
    ok)      printf 'no release due\n' ;;
    due)     printf 'release due: %s\n' "$reason" ;;
    overdue) printf 'release OVERDUE: %s\n' "$reason"
             [ "$annotate" -eq 1 ] && printf '::warning title=Release overdue::%s\n' "$reason"
             [ "$strict" -eq 1 ] && exit 1 ;;
  esac
  exit 0
fi
git remote get-url "$remote" >/dev/null 2>&1 || { sct_block "no remote '$remote'"; exit 2; }

# Fetch first. The number is derived from the default branch and the remote's tags; a stale
# remote-tracking ref would derive it from a range that is not the one being released.
git fetch -q --tags "$remote" || { sct_block "cannot fetch $remote"; sct_note "the release is derived from the remote's state, so it cannot be cut offline"; exit 2; }
def="$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null)"
def="${def#"$remote"/}"; [ -n "$def" ] || def=main
base="$remote/$def"
git rev-parse --verify --quiet "$base" >/dev/null || { sct_block "no $base after fetching"; exit 2; }

# NO `producer | grep -q` IN THIS FILE. Under pipefail, grep -q exits at its first match and the
# producer's next write dies of SIGPIPE, so the pipeline reports failure on a match. The release
# notes are long enough for that to happen, and it would read as "the notes are empty". Every
# test below reads a variable through a here-string instead.
remote_latest="$(git ls-remote --tags --refs --sort=-v:refname "$remote" 'v*' 2>/dev/null |
                 sed 's|.*refs/tags/||' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)"
local_latest="$(git tag --list 'v*' --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1)"
if [ -n "$local_latest" ] && [ "$local_latest" != "$remote_latest" ] &&
   [ -z "$(git ls-remote --tags --refs "$remote" "refs/tags/$local_latest")" ]; then
  sct_block "$local_latest exists in this checkout and not on $remote"
  sct_note "a tag nobody can fetch is not a release. Push it (git push $remote refs/tags/$local_latest)"
  sct_note "or delete it (git tag -d $local_latest), then run this again"
  exit 1
fi

on_base="$(git show "$base:VERSION" 2>/dev/null | tr -d '[:space:]')"

# The notes for a version: the lines after its heading, up to the next version heading.
section() { # <ref> <heading regex>
  git show "$1:CHANGELOG.md" 2>/dev/null |
    awk -v h="$2" 'f && /^### /{exit} f{print} $0 ~ h {f=1}'
}

if [ "$mode" = prepare ]; then
  [ -z "$(git status --porcelain)" ] || { sct_block "the working tree has uncommitted changes"; sct_note "a release commit carries VERSION and CHANGELOG.md and nothing else"; exit 1; }
  if [ -n "$remote_latest" ] && [ "$on_base" != "${remote_latest#v}" ]; then
    sct_block "$base already sets VERSION to $on_base, and v$on_base is not tagged"
    sct_note "the release is prepared and merged; sign and push its tag with: sct release --tag"
    exit 1
  fi
  next_out="$(bash scripts/check-version-bump.sh --print-next --ref "$base")"; rc=$?
  if [ "$rc" -eq 3 ]; then printf 'nothing to release: %s has no commits since %s\n' "$base" "$remote_latest"; exit 0; fi
  [ "$rc" -eq 0 ] || { sct_block "cannot derive the next version from $base"; exit 2; }
  next="${next_out%% *}"; level="${next_out#* }"
  unreleased_notes="$(section "$base" '^## Unreleased[[:space:]]*$')"
  if ! grep -q '[^[:space:]]' <<<"$unreleased_notes"; then
    sct_block "the Unreleased section of CHANGELOG.md on $base is empty"
    sct_note "write the notes first, in the pull requests that made the changes: an upgrade"
    sct_note "nobody can describe is an upgrade nobody can review (G47)"
    exit 1
  fi
  branch="chore/release-$next"
  git switch -q -c "$branch" "$base" 2>/dev/null || { sct_block "cannot create $branch (it may exist already)"; exit 1; }
  printf '%s\n' "$next" > VERSION
  heading="### $next - $(date -u +%Y-%m-%d)"
  tmp="$(mktemp)"
  awk -v h="$heading" '{print} !d && /^## Unreleased[[:space:]]*$/ {print ""; print h; d=1}' CHANGELOG.md > "$tmp" && cat "$tmp" > CHANGELOG.md
  rm -f "$tmp"
  git add VERSION CHANGELOG.md
  range="${remote_latest:-the first commit}..$base"
  if ! git commit -q -m "chore(release): $next" -m "Derived from ${range}: a $level change, so ${remote_latest#v} -> $next. Written by sct release."; then
    sct_block "the release commit failed"; exit 1
  fi
  if ! bash scripts/check-version-bump.sh --quiet --range "$base..HEAD" --subject "chore(release): $next"; then
    sct_block "the release commit does not pass the version gate"; exit 1
  fi
  printf 'prepared %s on %s (%s change since %s)\n' "$next" "$branch" "$level" "${remote_latest:-the start}"
  printf 'next: open the pull request (sc-open-pr), titled "chore(release): %s"; after it merges,\n' "$next"
  printf '      run sct release --tag\n'
  exit 0
fi

# ---- --tag
v="$on_base"; tag="v$v"
[ -n "$v" ] || { sct_block "no VERSION on $base"; exit 2; }
if [ -n "$(git ls-remote --tags --refs "$remote" "refs/tags/$tag")" ]; then
  printf '%s is already released on %s\n' "$tag" "$remote"; exit 0
fi
if [ -n "$remote_latest" ] && [ "$v" = "${remote_latest#v}" ]; then
  printf 'nothing to tag: VERSION on %s is %s, the newest release\n' "$base" "$v"; exit 0
fi
commit="$(git log -1 --format=%H "$base" -- VERSION)"
subject="$(git log -1 --format=%s "$commit")"
grep -qE '^chore\(release\)!?: ' <<<"$subject" || {
  sct_block "the commit that set VERSION to $v is not a release commit: $subject"
  sct_note "a tag goes on a chore(release) commit; cut one with: sct release"; exit 1; }
[ "$(git show "$commit:VERSION" | tr -d '[:space:]')" = "$v" ] || { sct_block "VERSION at ${commit:0:7} is not $v"; exit 1; }
notes="$(section "$commit" "^### $v - ")"
grep -q '[^[:space:]]' <<<"$notes" || { sct_block "CHANGELOG.md at ${commit:0:7} has no notes under ### $v"; exit 1; }

if git rev-parse --verify --quiet "refs/tags/$tag" >/dev/null; then
  [ "$(git rev-parse "$tag^{commit}")" = "$commit" ] || { sct_block "a local $tag points somewhere other than ${commit:0:7}"; sct_note "delete it (git tag -d $tag) and run this again"; exit 1; }
else
  msg="$(mktemp)"; { printf '%s\n\n' "$v"; printf '%s\n' "$notes"; } > "$msg"
  git tag -s "$tag" -F "$msg" "$commit" || { rm -f "$msg"; sct_block "signing $tag failed"; sct_note "a release tag is signed or it is not cut"; exit 1; }
  rm -f "$msg"
fi
git tag -v "$tag" >/dev/null 2>&1 || { sct_block "$tag does not verify"; sct_note "it is local only; remove it with git tag -d $tag"; exit 1; }
printf 'signed %s on %s (%s)\n' "$tag" "${commit:0:7}" "$subject"
if [ "$push" -eq 0 ]; then
  printf 'not pushed: git push %s refs/tags/%s\n' "$remote" "$tag"; exit 0
fi
git push -q "$remote" "refs/tags/$tag" || { sct_block "pushing $tag failed; it is signed locally"; exit 1; }
printf 'released %s\n' "$tag"
