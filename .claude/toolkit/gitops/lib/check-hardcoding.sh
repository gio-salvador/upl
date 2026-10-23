#!/usr/bin/env bash
# check-hardcoding.sh - shared hardcoding and secret-placement linter.
#
# One implementation, and these callers: the pre-push hook (through push-hardcoding.sh beside
# this file), CI, the sc-config-audit skill and its agent, and `sc-secret check`. It is the
# PLACEMENT and HARDCODING gate; it never re-implements gitleaks' secret-CONTENT entropy
# detection (G20).
#
# It flags three things:
#   1. paths        - an absolute macOS home path naming a real user, and a home-relative
#                     project path at ANY depth. There is no compliant fallback form: a location
#                     resolves from the path registry or a declared variable, and one that does
#                     not resolve is never guessed (G18, TK-121). The placeholder spelling with
#                     an angle bracket is matched on purpose, because that is how the retired
#                     fallback was documented. The config home is not flagged.
#   2. secret-file  - a file whose NAME says it holds a secret: the dotenv file, a key or tfvars
#                     extension, a name beginning id_, a name that IS secret, secrets or token
#                     (or begins client_secret), or that extension. A name that merely contains
#                     one of those words is not a finding (TK-122).
#   3. shell-secret - a shell source with a LITERAL credential assignment. A variable reference,
#                     a command substitution, a placeholder or an empty value is not a literal.
#
# Scope: every file in the run that is not binary. Exempt: templates ending .example, the
# secrets registry, the sc-secret accessor, the allowlist, plans, this file, and a vendored
# toolkit copy under .claude/toolkit/ (the host cannot fix it, and `sct vendor --check` already
# verifies it).
#
# Two kinds of run:
#   whole-tree  no --range. Every tracked file and every untracked file that is not ignored.
#   range       --range BASE..TIP. The files the range changes, their content AND the allowlist
#               read from TIP, so a push is judged on what it pushes and an allowlist line added
#               in the same push takes effect in it. A file absent at TIP is skipped.
#
# Severity. secret-file and shell-secret findings BLOCK. Path findings WARN unless:
#   --paths-block       every path finding blocks.
#   --paths-block-new   in a range run, a path finding on a line the range adds or changes
#                       blocks (an INTRODUCED finding); the rest stay warnings. In a whole-tree
#                       run there is no added-line information, so this blocks nothing.
#
# Per-repo allowlist `<root>/.claude/hardcoding-allow` (one `pattern  # justification` per line;
# a finding is suppressed when its `file:line` or matched text CONTAINS the pattern, so an entry
# also suppresses any other finding on a line that contains it).
# Emergency bypass `GITOPS_ALLOW_HARDCODE=1` (logged), mirroring `GITOPS_ALLOW_MAIN`.
#
# Usage: check-hardcoding.sh [--root DIR] [--range BASE..TIP] [--paths-block|--paths-block-new] [--quiet]
# Exit:  0 clean (or only WARN), 1 blocking finding(s), 2 usage/environment error.
set -uo pipefail

root="" range="" paths_block=0 paths_block_new=0 quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    --range) range="${2:-}"; shift 2 ;;
    --paths-block) paths_block=1; shift ;;
    --paths-block-new) paths_block_new=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,45p' "$0"; exit 0 ;;
    *) echo "check-hardcoding: unknown arg '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$root" ] || root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$root" ] || [ ! -d "$root" ]; then
  echo "check-hardcoding: --root is not a directory" >&2; exit 2
fi

base="" tip=""
if [ -n "$range" ]; then
  case "$range" in
    *...*) echo "check-hardcoding: --range takes BASE..TIP, not a three-dot range" >&2; exit 2 ;;
    *..*)  base="${range%%..*}"; tip="${range#*..}" ;;
    *)     echo "check-hardcoding: --range takes BASE..TIP" >&2; exit 2 ;;
  esac
  for rev in "$base" "$tip"; do
    git -C "$root" rev-parse --verify --quiet "$rev^{commit}" >/dev/null 2>&1 \
      || { echo "check-hardcoding: '$rev' is not a commit in $root" >&2; exit 2; }
  done
fi

exempt_path() {
  case "$1" in
    *.example|*secrets-registry.yaml|*/sc-secret|sc-secret|.claude/hardcoding-allow|docs/plans/*|*/check-hardcoding.sh) return 0 ;;
    .claude/toolkit/*) return 0 ;;
    *) return 1 ;;
  esac
}

# The NAME says the file holds a secret. Substring matching was the old rule, and it blocked a
# scanner script and a word list for mentioning the word (TK-122).
secret_name() {
  local b="${1##*/}" stem
  case "$b" in
    .env|*.key|*.tfvars|id_*) return 0 ;;
    *.secret|*.secrets|*.token) return 0 ;;
  esac
  stem="${b#.}"; stem="${stem%%.*}"
  case "$stem" in secret|secrets|token|client_secret*) return 0 ;; esac
  return 1
}

# Allowlist (patterns; blank lines and # comments ignored). Read from the tip in a range run.
allow=()
allow_src() {
  if [ -n "$tip" ]; then git -C "$root" show "$tip:.claude/hardcoding-allow" 2>/dev/null || true
  elif [ -r "$root/.claude/hardcoding-allow" ]; then cat "$root/.claude/hardcoding-allow"; fi
}
while IFS= read -r line; do
  line="${line%%#*}"
  line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
  [ -n "$line" ] && allow+=("$line")
done < <(allow_src)
allowed() {
  local hay="$1" p
  for p in "${allow[@]:-}"; do
    if [ -n "$p" ]; then
      case "$hay" in *"$p"*) return 0 ;; esac
    fi
  done
  return 1
}

# The files in the run. bash 3.2 has no mapfile, so read into a plain array.
files=()
list_files() {
  if [ -n "$tip" ]; then git -C "$root" diff --name-only --diff-filter=d "$base" "$tip" 2>/dev/null || true
  else git -C "$root" ls-files --cached --others --exclude-standard 2>/dev/null || true; fi
}
while IFS= read -r line; do [ -n "$line" ] && files+=("$line"); done < <(list_files)

# One file's content: from the tip in a range run, from disk otherwise.
content() {
  if [ -n "$tip" ]; then git -C "$root" show "$tip:$1" 2>/dev/null
  else [ -f "$root/$1" ] && cat "$root/$1"; fi
}

# Line numbers a range adds or changes in one file, from its zero-context diff. A moved line
# counts as added: touching it is the moment to fix it or allowlist it.
added_file="" added_list=""
is_added() { # file line
  [ -n "$tip" ] || return 1
  if [ "$added_file" != "$1" ]; then
    added_file="$1"
    added_list="$(git -C "$root" diff -U0 "$base" "$tip" -- "$1" 2>/dev/null | awk '
      /^@@ / { split($3, a, ","); s = substr(a[1], 2) + 0; n = (a[2] == "" ? 1 : a[2] + 0)
               for (i = 0; i < n; i++) print s + i }')"
  fi
  grep -qx "$2" <<<"$added_list"
}

block=0 warn=0
emit() { # severity file line rule snippet
  local sev="$1" file="$2" ln="$3" rule="$4" snip="$5"
  if allowed "$file:$ln" || allowed "$snip"; then return 0; fi
  [ "$quiet" -eq 1 ] || printf '%s  %s:%s  %s — %s\n' "$sev" "$file" "$ln" "$rule" "$snip"
  case "$sev" in BLOCK) block=$((block+1)) ;; WARN) warn=$((warn+1)) ;; esac
}

re_users='/Users/[A-Za-z0-9][A-Za-z0-9._-]*'
re_proj='(\$HOME|\$\{HOME\}|~)/projects/[A-Za-z0-9_<-]'
re_assign='(export[[:space:]]+)?([A-Za-z_]*(TOKEN|SECRET|API_?KEY|_KEY|PASSWORD|PASSWD|PSWD|PWD|CREDENTIAL|PASSPHRASE)[A-Za-z_]*|[A-Za-z_]*_(PASS|PW))='

# 2 and 3: by name, and literal assignments in shell sources.
for f in "${files[@]:-}"; do
  [ -n "$f" ] || continue
  if exempt_path "$f"; then continue; fi

  if secret_name "$f"; then
    emit BLOCK "$f" 0 "secret-file (tracked secret-shaped name)" "$f"
  fi

  case "$f" in
    *.sh|*.zsh|*.bash)
      while IFS=: read -r ln text; do
        [ -n "$ln" ] || continue
        case "$text" in \#*) continue ;; esac                       # pure comment
        # The shell's own working-directory variables are not credentials.
        name="$(printf '%s' "$text" | grep -oE "$re_assign" | head -1)"
        name="${name%=}"; name="${name#export}"; name="${name#"${name%%[![:space:]]*}"}"
        case "$name" in PWD|OLDPWD) continue ;; esac
        # `KEY="$var"` is a variable reference and cannot be a literal, the same as `$(...)`
        # and `${...}` beside it. Without this the linter blocked `GH_TOKEN="$tok"`, which is
        # precisely the safe way to pass a secret to one command (TK-082).
        #
        # The `\\?` before each `$` admits the ESCAPED form. Guidance that teaches the safe
        # pattern has to quote it, and inside a double-quoted shell string that is written
        # `GH_TOKEN=\$(gh auth token ...)`. The linter blocked exactly the advice that tells a
        # reader not to hardcode a token, which is the worst possible false positive: it
        # pressures the author into deleting the lesson rather than the secret.
        if grep -Eq '=[[:space:]]*("?)(\\?\$\(|\\?\$\{|\\?\$[A-Za-z_]|""|'"''"'|XXX|REPLACE|CHANGE|TODO|<|$)' <<<"$text"; then
          continue                                                  # value is a lookup/placeholder/empty
        fi
        # `KEY=` with nothing before the next word CLEARS the variable for one command
        # (`GH_TOKEN= GITHUB_TOKEN= gh auth token ...`). An empty value is the absence of a
        # secret, and this idiom is how a lookup is made to run with no ambient credential.
        if grep -Eq '=([[:space:]]|$)' <<<"$text"; then
          continue
        fi
        emit BLOCK "$f" "$ln" "literal secret in shell source (move to sc-secret)" "$(printf '%s' "$text" | sed -E 's/=.{6,}/= ***REDACTED***/' | head -c 80)"
      done < <(content "$f" | grep -nE "$re_assign" 2>/dev/null || true)
      ;;
  esac
done

# 1: paths. One pass over the whole tree, or one read per changed file from the tip. Both print
# `file:line:text`, and both skip binaries.
path_hits() {
  local f
  if [ -n "$tip" ]; then
    for f in "${files[@]:-}"; do
      [ -n "$f" ] || continue
      content "$f" | grep -nIE -e "$re_users" -e "$re_proj" 2>/dev/null | F="$f" awk '{ print ENVIRON["F"] ":" $0 }' || true
    done
  else
    git -C "$root" grep -nIE --untracked -e "$re_users" -e "$re_proj" 2>/dev/null || true
  fi
}
while IFS=: read -r f ln text; do
  [ -n "$f" ] && [ -n "$ln" ] || continue
  if exempt_path "$f"; then continue; fi
  sev="WARN" tag=""
  if [ "$paths_block" -eq 1 ]; then sev="BLOCK"; fi
  if is_added "$f" "$ln"; then
    tag=", introduced"
    [ "$paths_block_new" -eq 1 ] && sev="BLOCK"
  fi
  if grep -Eq "$re_users" <<<"$text"; then
    emit "$sev" "$f" "$ln" "hardcoded home path$tag" "$(printf '%s' "$text" | grep -oE "$re_users" | head -1)"
  else
    emit "$sev" "$f" "$ln" "home-relative project path (resolve it from the registry or a declared variable)$tag" "$(printf '%s' "$text" | grep -oE "${re_proj}[A-Za-z0-9_./<>-]*" | head -1)"
  fi
done < <(path_hits)

if [ "$block" -gt 0 ] && [ "${GITOPS_ALLOW_HARDCODE:-0}" = "1" ]; then
  echo "!! GITOPS_ALLOW_HARDCODE=1 — $block blocking hardcoding/secret finding(s) bypassed in $root" >&2
  block=0
fi

[ "$quiet" -eq 1 ] || printf 'check-hardcoding: %d block, %d warn (root %s%s)\n' "$block" "$warn" "$root" "${range:+, range $range}"
[ "$block" -eq 0 ]
