#!/usr/bin/env bash
# Shared helpers for every toolkit script. Sourced, never executed.
#
# Design rules this file exists to hold in one place (Goal G17, single source of truth):
#   - no absolute paths, ever (G18)
#   - resolution records which layer answered (G37)
#   - optional dependencies degrade cleanly and SAY SO, never silently skip a gate (G44)
#   - output is silent when clean (G26)

# shellcheck shell=bash

SCT_RED=$'\033[31m'; SCT_YEL=$'\033[33m'; SCT_DIM=$'\033[2m'; SCT_OFF=$'\033[0m'
[ -t 2 ] || { SCT_RED=""; SCT_YEL=""; SCT_DIM=""; SCT_OFF=""; }

sct_block() { printf '%sBLOCK%s  %s\n' "$SCT_RED" "$SCT_OFF" "$*" >&2; }
sct_warn()  { printf '%swarn%s   %s\n'  "$SCT_YEL" "$SCT_OFF" "$*" >&2; }
sct_note()  { printf '%s       %s%s\n'  "$SCT_DIM" "$*" "$SCT_OFF" >&2; }

# Pin the git root. Every path a tool touches must live inside it.
sct_root() {
  local r; r="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$r" ] || { sct_block "not inside a git repository"; return 2; }
  printf '%s' "$r"
}

# The toolkit's own directory, wherever it was installed or vendored to.
# Follows symlinks: a script sourced through an installed link must still find the toolkit,
# not the link's directory.
sct_home() {
  local src="${BASH_SOURCE[0]}" dir d
  while [ -L "$src" ]; do
    dir="$(cd -P "$(dirname "$src")" && pwd)"
    src="$(readlink "$src")"
    case "$src" in /*) ;; *) src="$dir/$src" ;; esac
  done
  d="$(cd -P "$(dirname "$src")/.." && pwd)"
  printf '%s' "$d"
}

sct_version() {
  local h; h="$(sct_home)"
  [ -r "$h/VERSION" ] && tr -d '[:space:]' < "$h/VERSION" || printf 'unknown'
}

# Optional dependency. Returns 1 when absent, and the caller must say what it degraded to.
sct_have() { command -v "$1" >/dev/null 2>&1; }

# Required dependency. Fails closed.
sct_need() {
  sct_have "$1" && return 0
  sct_block "required dependency missing: $1"
  return 1
}

# Enumerate tracked files (G31: git ls-files, never a filesystem walk, so .gitignore is
# honoured without this code needing to know what it excludes).
sct_tracked() { git -C "${1:-.}" ls-files; }

# Resolve a setting through the precedence chain (TK-010), echoing "<value>\t<layer>".
# Layers, most specific first: repo local override, repo profile, global instance, vendored
# default. A repo that declares itself self_contained skips the global layer.
sct_resolve() {
  local key="$1" root="$2" out=""
  local local_f="$root/.claude/profile.local.yaml"
  local prof_f="$root/.claude/profile.yaml"
  local glob_f="${CLAUDE_CONFIG_HOME:-$HOME/.claude}/config/profile.yaml"
  local self_contained=no
  [ -r "$prof_f" ] && grep -Eq '^[[:space:]]*self_contained:[[:space:]]*true' "$prof_f" && self_contained=yes

  out="$(sct_yaml_get "$local_f" "$key")"; [ -n "$out" ] && { printf '%s\tlocal-override' "$out"; return 0; }
  out="$(sct_yaml_get "$prof_f"  "$key")"; [ -n "$out" ] && { printf '%s\trepo-profile'   "$out"; return 0; }
  if [ "$self_contained" = no ]; then
    out="$(sct_yaml_get "$glob_f" "$key")"; [ -n "$out" ] && { printf '%s\tglobal-instance' "$out"; return 0; }
  fi
  out="$(sct_yaml_get "$(sct_home)/config/defaults.yaml" "$key")"
  [ -n "$out" ] && { printf '%s\tvendored-default' "$out"; return 0; }
  return 1
}

# Minimal dotted-key reader for the flat and one-level-nested YAML these manifests use.
# Deliberately not a YAML parser: the schema keeps the shapes simple enough that a parser
# would be a dependency bought for nothing (G44, G56).
sct_yaml_get() {
  local file="$1" key="$2"
  [ -r "$file" ] || return 1
  case "$key" in
    *.*)
      local top="${key%%.*}" leaf="${key#*.}"
      awk -v top="$top" -v leaf="$leaf" '
        $0 ~ "^"top":[[:space:]]*$" { inb=1; next }
        inb && /^[^[:space:]#]/ { inb=0 }
        inb && $0 ~ "^[[:space:]]+"leaf":" {
          sub(/^[[:space:]]*[A-Za-z0-9_-]+:[[:space:]]*/, ""); gsub(/^["\x27]|["\x27]$/, "");
          sub(/[[:space:]]+#.*$/, ""); print; exit }
      ' "$file"
      ;;
    *)
      awk -v k="$key" '
        $0 ~ "^"k":" { sub(/^[A-Za-z0-9_-]+:[[:space:]]*/, ""); gsub(/^["\x27]|["\x27]$/, "");
                       sub(/[[:space:]]+#.*$/, ""); print; exit }
      ' "$file"
      ;;
  esac
}

# The newest RELEASE, which is what a repository can actually be behind. While the toolkit is
# developed unreleased (TK-064) `main` moves constantly, so comparing a pin against `main` marks
# every repository stale the moment anything merges. A signal that is always on is not a signal.
sct_latest_release() {
  git -C "$(sct_home)" tag --sort=-v:refname 2>/dev/null | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | head -1
}

# Classify a pinned version against the newest release. Echoes one of:
#   not-covered | behind <release> | current | current+<n> | unknown
# `current+<n>` means the pin is the newest release plus n unreleased commits: expected while
# developing, and deliberately NOT called stale, because there is nothing for the operator to do
# about it until a release happens (TK-072).
sct_pin_state() {
  local pin="$1" latest; latest="$(sct_latest_release)"
  [ -n "$pin" ] || { printf 'not-covered'; return; }
  [ -n "$latest" ] || { printf 'unknown'; return; }
  local base ahead
  base="${pin%%-*}"                       # v0.5.2-7-g70ce52a -> v0.5.2
  case "$pin" in *-*-g*) ahead="${pin#*-}"; ahead="${ahead%%-*}" ;; *) ahead=0 ;; esac
  local nb nl
  nb="$(printf '%s' "${base#v}" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')"
  nl="$(printf '%s' "${latest#v}" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')"
  if [ "$nb" -lt "$nl" ] 2>/dev/null; then printf 'behind %s' "$latest"; return; fi
  [ "$ahead" = "0" ] && printf 'current' || printf 'current+%s' "$ahead"
}

# Run `gh` pinned to a NAMED account, never to whichever one happens to be active.
#
# `gh`'s active account is global mutable state shared by every process on this machine. A
# concurrent session, a hook, or a tool defaulting to its own account can move it mid-run, and it
# did: three times in one session, after an explicit `gh auth switch`, with no command in that
# session switching it back (TK-082). Every call that names a repository therefore runs under an
# account nobody in that call chose.
#
# What makes it dangerous rather than untidy is the shape of the failure. GitHub answers "you
# cannot see this" and "this does not exist" with the same 404, deliberately, so a call reading
# the answer as absence is confidently wrong rather than merely unlucky. That has already
# produced a wrong tier (TK-071) and a wrong adoption report (TK-082).
#
# `gh auth token --user` reads a stored token WITHOUT touching the active account, which is the
# property that makes pinning safe here: this neither depends on the shared state nor corrupts it
# for the session next door. `scripts/forge-visibility.sh` already relies on it for the same
# reason. The token reaches exactly one call through the environment and is never printed,
# logged, or written.
#
# DEGRADES WHEN IT CANNOT CHECK, BLOCKS WHEN IT IS WRONG. Two different failures, deliberately
# not collapsed. With no stored token for that account -- never authenticated as them, or the
# account is an organisation rather than a login -- this falls back to a bare `gh`, which is
# today's behaviour and no worse (G44). But a token that resolves to a DIFFERENT account is not
# an ambiguous case, it is the exact harm this helper exists to prevent, and it blocks.
#
# WHY THE PIN IS VERIFIED RATHER THAN TRUSTED (TK-104, 2026-09-01). The comment above used to
# assert that `gh auth token --user` returns that account's token. On this machine it does not:
# every `--user` returns the SAME token, because the accounts share one keyring slot, so the pin
# was a no-op and every pinned call silently ran as whoever the slot held. `gh auth switch` has
# the same defect from the other side -- it moves the label in `gh auth status` while leaving the
# credential alone, so the label and the effective identity disagree.
#
# Nothing caught it because every test stubs `gh`, and a stub that honours `--user` proves the
# logic and not the premise. The only trustworthy answer to "who am I" is `gh api user`, which
# asks the forge instead of reading local state, and that is what is asserted here. This is the
# same move the identity guard already makes for ssh, where the remote URL is not trusted either
# and the forge is asked directly (TK-041).
#
# Verified ONCE per account per process and cached, because this runs in loops and each check is
# a network round trip.
#
# Usage: sct_gh_as <account> <gh args...>. Exit status is gh's own; 127 if gh is absent, 3 if the
# pin resolved to the wrong account.
sct_gh_as() {
  local acct="${1:-}"; shift
  sct_have gh || return 127
  # THE LOOKUP RUNS WITH NO AMBIENT CREDENTIAL, BY CONSTRUCTION. `gh` consults GH_TOKEN and
  # GITHUB_TOKEN, and this helper sets GH_TOKEN itself for the call it wraps, so a nested or
  # already-pinned caller would otherwise be asking "which token is this account's" in an
  # environment that already asserts an answer. Whether today's `gh` prefers the environment here
  # is not the point: the premise that this returns the NAMED account's token should be true
  # because it was made true, not because a precedence rule currently happens to favour it. An
  # earlier reading of this helper was thrown by exactly that ambiguity and could not be settled
  # afterwards (TK-105).
  local tok=""
  [ -n "$acct" ] && tok="$(GH_TOKEN= GITHUB_TOKEN= gh auth token --user "$acct" 2>/dev/null || true)"
  [ -n "$tok" ] || { gh "$@"; return; }

  local cache_var state got
  cache_var="_sct_gh_as_$(printf '%s' "$acct" | tr -c 'A-Za-z0-9' '_')"
  eval "state=\${$cache_var:-}"
  if [ -z "$state" ]; then
    got="$(GH_TOKEN="$tok" gh api user --jq .login 2>/dev/null || true)"
    if [ -z "$got" ]; then state="degraded"
    elif [ "$got" = "$acct" ]; then state="ok"
    else state="wrong $got"; fi
    eval "$cache_var=\$state"
  fi

  case "$state" in
    ok) GH_TOKEN="$tok" gh "$@" ;;
    degraded)
      sct_warn "cannot confirm the token for '$acct' belongs to it: pin UNVERIFIED"
      sct_note "the forge could not be reached. the call proceeds pinned, as it did before."
      GH_TOKEN="$tok" gh "$@" ;;
    *)
      sct_block "forge pin failed: asked for '$acct', the token authenticates as '${state#wrong }'"
      sct_note "the label and the credential disagree: --user selected a name, not this token."
      sct_note "usually one credential serving several accounts. fix: gh auth login as '$acct'."
      return 3 ;;
  esac
}

# Can this repository's vendored gates run OFF this machine? Echoes one of:
#   ci gates    a workflow on the default branch invokes the vendored copy
#   ci other    workflows exist, but none of them runs the gates
#   hooks only  no workflows at all: the gates run only when a local hook fires
#   unknown     no default branch resolved, so nothing can be read from the repository
#
# ADOPTION IS NOT EXECUTION. `sct adopt` vendors the gates and pins them in
# `.claude/toolkit.lock`, and that is the whole of what adoption guarantees. Whether they ever
# run is the repository's own decision, and for most of this fleet the answer is "only when a
# local hook fires", which means a push from a machine where `core.hooksPath` is not set is
# completely ungated. Nothing measured that, so the gap was invisible and read as coverage.
#
# The signature is a workflow that names `.claude/toolkit`, because that is what running the
# VENDORED gates looks like: a repository's own bespoke CI is not evidence that the toolkit's
# checks execute, and counting it would restore exactly the false confidence this distinguishes.
# Reported as three states rather than a yes/no for the same reason -- "has CI" and "runs the
# gates" are different claims and collapsing them is what went wrong (TK-095).
#
# Read from the DEFAULT BRANCH, never the checkout: what a repository does in CI is a property
# of the repository, and reading the working tree answers a question about this machine
# (TK-033, 034, 043, 048, 049, 083).
#
# Usage: sct_ci_gates <repo-root> [default-branch-ref]
sct_ci_gates() {
  local repo="$1" ref="${2:-}"
  [ -n "$ref" ] || { printf 'unknown'; return; }
  local files; files="$(git -C "$repo" ls-tree -r --name-only "$ref" -- .github/workflows 2>/dev/null |
    grep -E '\.ya?ml$' || true)"
  [ -n "$files" ] || { printf 'hooks only'; return; }
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if git -C "$repo" show "$ref:$f" 2>/dev/null | grep -q '\.claude/toolkit'; then
      printf 'ci gates'; return
    fi
  done <<< "$files"
  printf 'ci other'
}

# A version string as a sortable integer, so two pins can be compared. `v0.6.4` and `0.6.4` are
# the same version, and a `-7-g70ce52a` suffix describes commits past a release rather than a
# different one, so it is dropped: this compares releases, not builds.
# Echoes nothing for an unparseable version, which the caller must treat as "cannot compare"
# rather than as zero.
sct_ver_num() {
  local v="${1:-}"; v="${v#v}"; v="${v%%-*}"
  case "$v" in [0-9]*.[0-9]*.[0-9]*) ;; *) return 1 ;; esac
  printf '%s' "$v" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}'
}

# A duration in seconds as a coarse human phrase: "3 minutes", "5 hours", "2 days". Deliberately
# one unit and no decimals, because this qualifies an answer rather than measuring anything.
sct_duration() {
  local s="${1:-0}"
  if [ "$s" -lt 90 ] 2>/dev/null; then printf '%d seconds' "$s"
  elif [ "$s" -lt 5400 ] 2>/dev/null; then printf '%d minutes' "$((s / 60))"
  elif [ "$s" -lt 172800 ] 2>/dev/null; then printf '%d hours' "$((s / 3600))"
  else printf '%d days' "$((s / 86400))"; fi
}
