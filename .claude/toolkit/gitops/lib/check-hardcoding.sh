#!/usr/bin/env bash
# check-hardcoding.sh — shared hardcoding + secret-placement linter.
#
# One implementation, three callers: the gitops pre-push hook, the sc-config-audit skill,
# and an optional CI step. It is the PLACEMENT and HARDCODING gate; it never re-implements
# gitleaks' secret-CONTENT entropy detection (strict split, plan §9).
#
# It flags three things over a repo's tooling surfaces:
#   1. paths       — absolute `/Users/...` paths, and `$HOME`/`~` paths deeper than a project
#                    root. Compliant root-only fallbacks (`$HOME/projects/<name>` with no
#                    trailing segment) and the config home (`$HOME/.claude/...`) are NOT flagged.
#   2. secret-file — tracked files whose NAME matches a secret pattern (.env, *secret*, *token*,
#                    *.key, *.tfvars, id_*): a placement violation regardless of content.
#   3. shell-secret — tracked *.sh/*.zsh/*.bash with a LITERAL secret assignment
#                    (`FOO_TOKEN=<real value>`). This catches secrets hidden in shell sources
#                    that the name patterns and gitleaks-history both miss (e.g. src_cloudflare.sh).
#
# Severity: secret-file and shell-secret findings BLOCK on every tier (cleanup precedes wiring).
# path findings WARN by default; pass --paths-block to make them blocking.
#
# Per-repo allowlist `<root>/.claude/hardcoding-allow` (one `pattern  # justification` per line;
# a finding is suppressed when its `file:line` or matched text contains the pattern).
# Emergency bypass `GITOPS_ALLOW_HARDCODE=1` (logged), mirroring `GITOPS_ALLOW_MAIN`.
#
# Usage: check-hardcoding.sh [--root DIR] [--range A..B] [--paths-block] [--quiet]
# Exit:  0 clean (or only WARN), 1 blocking finding(s), 2 usage/environment error.
set -uo pipefail

root="" range="" paths_block=0 quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    --range) range="${2:-}"; shift 2 ;;
    --paths-block) paths_block=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "check-hardcoding: unknown arg '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$root" ] || root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$root" ] || [ ! -d "$root" ]; then
  echo "check-hardcoding: --root is not a directory" >&2; exit 2
fi

# Tooling surfaces we scan: user-level tools (claude/), project tooling (.claude/, scripts/,
# hooks/), and shell sources anywhere (src_*.sh, *.sh) for the shell-secret check.
in_scope() {
  case "$1" in
    .claude/*|claude/*|scripts/*|hooks/*|*.sh|*.zsh|*.bash) return 0 ;;
    *) return 1 ;;
  esac
}
# Never flag our own template/registry/doc/allowlist/helper surfaces.
exempt_path() {
  case "$1" in
    *.example|*secrets-registry.yaml|*/sc-secret|sc-secret|.claude/hardcoding-allow|docs/plans/*|*/check-hardcoding.sh) return 0 ;;
    *) return 1 ;;
  esac
}

# Allowlist (patterns; blank lines and # comments ignored).
allow=()
if [ -r "$root/.claude/hardcoding-allow" ]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] && allow+=("$line")
  done < "$root/.claude/hardcoding-allow"
fi
allowed() {
  local hay="$1" p
  for p in "${allow[@]:-}"; do
    if [ -n "$p" ]; then
      case "$hay" in *"$p"*) return 0 ;; esac
    fi
  done
  return 1
}

# Tracked + not-ignored files (mirrors the hook). bash 3.2 has no mapfile/assoc-arrays, so
# read into a plain array. Range mode narrows to a push's changed files.
files=()
while IFS= read -r line; do [ -n "$line" ] && files+=("$line"); done \
  < <(git -C "$root" ls-files --cached --others --exclude-standard 2>/dev/null || true)
if [ -n "$range" ]; then
  changed_list="$(git -C "$root" diff --name-only "$range" 2>/dev/null || true)"
  filtered=()
  for f in "${files[@]:-}"; do
    if printf '%s\n' "$changed_list" | grep -qxF "$f"; then filtered+=("$f"); fi
  done
  files=("${filtered[@]:-}")
fi

block=0 warn=0
emit() { # severity file line rule snippet
  local sev="$1" file="$2" ln="$3" rule="$4" snip="$5"
  if allowed "$file:$ln" || allowed "$snip"; then return 0; fi
  [ "$quiet" -eq 1 ] || printf '%s  %s:%s  %s — %s\n' "$sev" "$file" "$ln" "$rule" "$snip"
  case "$sev" in BLOCK) block=$((block+1)) ;; WARN) warn=$((warn+1)) ;; esac
}

re_users='/Users/[A-Za-z0-9._-]+'
re_deep='(\$HOME|~)/projects/[A-Za-z0-9_-]+/'
re_secretname='(^|/)(\.env|[^/]*secret[^/]*|[^/]*token[^/]*|[^/]*\.key|[^/]*\.tfvars|id_[^/]*)$'
re_assign='(export[[:space:]]+)?[A-Za-z_]*(TOKEN|SECRET|API_?KEY|_KEY|PASSWORD|PASSWD|CREDENTIAL|PASSPHRASE)[A-Za-z_]*='
sev_path="WARN"; [ "$paths_block" -eq 1 ] && sev_path="BLOCK"

for f in "${files[@]:-}"; do
  [ -n "$f" ] || continue
  in_scope "$f" || continue
  if exempt_path "$f"; then continue; fi
  abs="$root/$f"; [ -f "$abs" ] || continue

  # 2. secret-file by name (placement) — BLOCK.
  if printf '%s' "$f" | grep -Eq "$re_secretname"; then
    emit BLOCK "$f" 0 "secret-file (tracked secret-shaped name)" "$f"
  fi

  grep -Iq . "$abs" 2>/dev/null || continue   # skip binaries

  # 1. paths (deep / absolute).
  while IFS=: read -r ln text; do
    [ -n "$ln" ] || continue
    if printf '%s' "$text" | grep -Eq "$re_users"; then
      emit "$sev_path" "$f" "$ln" "hardcoded /Users path" "$(printf '%s' "$text" | grep -oE "$re_users" | head -1)"
    elif printf '%s' "$text" | grep -Eq "$re_deep"; then
      emit "$sev_path" "$f" "$ln" "deep \$HOME/~ path (root-only allowed)" "$(printf '%s' "$text" | grep -oE "${re_deep}[A-Za-z0-9_./-]*" | head -1)"
    fi
  done < <(grep -nE "$re_users|$re_deep" "$abs" 2>/dev/null || true)

  # 3. shell-secret literal assignment (placement) — BLOCK. Shell sources only.
  case "$f" in
    *.sh|*.zsh|*.bash)
      while IFS=: read -r ln text; do
        [ -n "$ln" ] || continue
        case "$text" in \#*) continue ;; esac                       # pure comment
        # `KEY="$var"` is a variable reference and cannot be a literal, the same as `$(...)`
        # and `${...}` beside it. Without this the linter blocked `GH_TOKEN="$tok"`, which is
        # precisely the safe way to pass a secret to one command (TK-082).
        #
        # The `\\?` before each `$` admits the ESCAPED form. Guidance that teaches the safe
        # pattern has to quote it, and inside a double-quoted shell string that is written
        # `GH_TOKEN=\$(gh auth token ...)`. The linter blocked exactly the advice that tells a
        # reader not to hardcode a token, which is the worst possible false positive: it
        # pressures the author into deleting the lesson rather than the secret.
        if printf '%s' "$text" | grep -Eq '=[[:space:]]*("?)(\\?\$\(|\\?\$\{|\\?\$[A-Za-z_]|""|'"''"'|XXX|REPLACE|CHANGE|TODO|<|$)'; then
          continue                                                  # value is a lookup/placeholder/empty
        fi
        # `KEY=` with nothing before the next word CLEARS the variable for one command
        # (`GH_TOKEN= GITHUB_TOKEN= gh auth token ...`). An empty value is the absence of a
        # secret, and this idiom is how a lookup is made to run with no ambient credential.
        if printf '%s' "$text" | grep -Eq '=([[:space:]]|$)'; then
          continue
        fi
        emit BLOCK "$f" "$ln" "literal secret in shell source (move to sc-secret)" "$(printf '%s' "$text" | sed -E 's/=.{6,}/= ***REDACTED***/' | head -c 80)"
      done < <(grep -nE "$re_assign" "$abs" 2>/dev/null || true)
      ;;
  esac
done

if [ "$block" -gt 0 ] && [ "${GITOPS_ALLOW_HARDCODE:-0}" = "1" ]; then
  echo "!! GITOPS_ALLOW_HARDCODE=1 — $block blocking hardcoding/secret finding(s) bypassed in $root" >&2
  block=0
fi

[ "$quiet" -eq 1 ] || printf 'check-hardcoding: %d block, %d warn (root %s%s)\n' "$block" "$warn" "$root" "${range:+, range $range}"
[ "$block" -eq 0 ]
