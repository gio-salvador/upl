#!/usr/bin/env bash
# Validation coverage gate (Goal G51).
#
# Every other gate answers "is this surface correct?". This one answers the question nobody
# asks: "is there any gate looking at this surface at all?"
#
# An unvalidated surface is not a passing surface, it is an unexamined one, and the two are
# indistinguishable in a green build. The same logic as the review lens rule: an applicable
# lens that was never selected is silently ungated content.
#
# Declares which gate owns which surface, then reports any tracked file type that no gate claims.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
cd "$root" || exit 2

# surface pattern | the gate that owns it
owned=(
  "*.md|check-docs.sh, check-style.sh"
  "*.sh|tests/run.sh syntax, check-hardcoding.sh"
  "*.py|tests/run.sh syntax"
  "*.json|validate.py where a schema exists"
  "*.yaml|validate.py where a schema exists"
  "*.yml|validate.py where a schema exists"
  "*.example|validate.py --instance"
  "LICENSE|not validated, and does not need to be"
  "CODEOWNERS|not validated, and does not need to be"
  ".gitignore|check-public-ready.sh (instance paths must be ignored)"
  "commit-msg|tests/run.sh syntax"
  "pre-commit|tests/run.sh syntax"
  "pre-push|tests/run.sh syntax"
  "sct|tests/run.sh syntax"
  "sc-secret|tests/run.sh syntax"
  "sc-env|tests/run.sh syntax"
  "VERSION|toolkit-lock.schema.json pattern, via the lockfile it is written into"
  "*.lock|toolkit-lock.schema.json"
  "*.txt|reviewed, not machine-validated"
  "*.css|not validated: no styling ships from this repository"
  ".gitleaks.toml|the secrets gate reads it, and CI proves it: a commit whose only
                  change is this file still has to pass the same gitleaks run"
)

claims() { # path -> owning gate, or empty
  local f="$1" e
  for e in "${owned[@]}"; do
    local pat="${e%%|*}" gate="${e#*|}"
    case "$f" in $pat) printf '%s' "$gate"; return 0 ;; esac
    case "$(basename "$f")" in $pat) printf '%s' "$gate"; return 0 ;; esac
  done
  return 1
}

# A tracked symlink pointing OUTSIDE the repository is always a finding, whatever its type.
# It means something wrote into this source tree through a link: the content is not really
# here, it is not reproducible from a clone, and on a machine without the link target the file
# is simply broken. This check exists because it happened: an installer linked a whole
# directory and a later per-item merge then wrote through it into this repository (TK-037).
escapes=0
while IFS= read -r f; do
  [ -L "$f" ] || continue
  tgt="$(readlink "$f")"
  case "$tgt" in
    /*) sct_block "tracked symlink escapes the repository: $f -> $tgt"; escapes=$((escapes+1)) ;;
    ../*) sct_block "tracked symlink escapes the repository: $f -> $tgt"; escapes=$((escapes+1)) ;;
  esac
done < <(sct_tracked "$root")
[ "$escapes" -gt 0 ] && { printf 'check-coverage: %d escaping symlink(s)\n' "$escapes" >&2; exit 1; }

# A host may declare owners for its own file types. The shipped table is the toolkit's, and a
# consuming repository has types the toolkit never has (.mjs, .gitmodules, extensionless data).
# Editing the table inside a vendored copy would be lost on the next upgrade.
if [ -r "$root/.claude/coverage-owners.txt" ]; then
  while IFS= read -r line; do
    line="${line%%#*}"
    case "$line" in *"|"*) owned+=("$line") ;; esac
  done < "$root/.claude/coverage-owners.txt"
  declared=1
else
  declared=0
fi

# STAGED, like the long-dash gate (TK-043). In the toolkit, or in a host that has declared its
# owners, an unclaimed surface BLOCKS. In a host that has declared nothing it is ADVISORY: the
# question "does a gate claim this file type" is the host's to answer, and failing its build over
# a table it never wrote is how an inherited gate gets deleted rather than adopted.
blocking=1
[ "$root" = "$(sct_home)" ] || [ "$declared" = "1" ] || blocking=0

unclaimed=0
declare -a seen=()
while IFS= read -r f; do
  # Vendored toolkit content is the toolkit's, gated in the toolkit's own CI. A host re-judging
  # it produces findings its author cannot act on, in files it did not write (TK-057).
  case "$f" in .claude/toolkit/*) continue ;; esac
  if ! claims "$f" >/dev/null; then
    kind="$(basename "$f")"; case "$kind" in *.*) kind=".${kind##*.}" ;; esac
    case " ${seen[*]:-} " in *" $kind "*) continue ;; esac
    seen+=("$kind")
    sct_warn "no gate claims this surface: $kind (first seen at $f)"
    sct_note "add it to the ownership table in this script, or state why it needs none"
    unclaimed=$((unclaimed+1))
  fi
done < <(sct_tracked "$root")

if [ "$unclaimed" -eq 0 ]; then
  [ "$quiet" -eq 1 ] || printf 'check-coverage: every tracked surface has an owning gate\n'
  exit 0
fi
if [ "$blocking" -eq 0 ]; then
  printf 'check-coverage: %d unclaimed surface type(s) (advisory: declare owners in .claude/coverage-owners.txt to enforce)\n' "$unclaimed" >&2
  exit 0
fi
printf 'check-coverage: %d unclaimed surface type(s)\n' "$unclaimed" >&2
exit 1
