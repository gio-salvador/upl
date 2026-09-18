#!/usr/bin/env bash
# Instruction ownership gate (Goal G59).
#
# Single ownership applies to the instructions themselves. Every skill and agent file is read on
# every run by every agent, so a rule restated in twelve files is not just a correctness risk
# when the copies drift: it is twelve times the tokens, on every run, forever.
#
# Two checks:
#   1. RESTATEMENT - a normative sentence that a fleet-level document already owns, repeated
#      verbatim-ish in a tool file. The tool should point at the owner instead.
#   2. CONTRADICTION - a tool file asserting the opposite of a fleet rule.
#
# Both are ADVISORY. Natural-language ownership cannot be decided mechanically, and a gate that
# blocks on a heuristic teaches people to bypass gates. It reports, a human decides.
#
# Usage: check-instructions.sh [--quiet]
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
cd "$root" || exit 2

# Scan the dirs this repository actually keeps its tools in. The globs were hardcoded to
# `skills/` and `agents/`, which is where the TOOLKIT keeps them; a consuming repository keeps
# them under `.claude/`, so the check scanned nothing there and passed vacuously. A gate that
# looks at no files is not a passing gate, and declaring it enforced would have been theatre
# (TK-074).
man="$root/.claude/docs-sync.yaml"
sk_dir="$(sct_yaml_get "$man" skills_dir 2>/dev/null)"; sk_dir="${sk_dir:-.claude/skills}"
ag_dir="$(sct_yaml_get "$man" agents_dir 2>/dev/null)"; ag_dir="${ag_dir:-.claude/agents}"
sk_glob="$sk_dir/*"; ag_glob="$ag_dir/*"

# Rules that have exactly one owner. A tool file restating one should reference it instead.
# Format: <owner-file>|<phrase that indicates a restatement>
rules=(
  "config/voice/core.md|British spelling"
  "config/voice/core.md|em dash"
  "config/voice/core.md|en dashes"
  "config/evidence-vocabulary.md|NEEDS-SOURCE"
  "config/execution-doctrine.md|cap at 3 rounds"
  "config/execution-doctrine.md|efficiency never buys"
  "config/verification-doctrine.md|correlated observations count once"
  "config/verification-doctrine.md|refutation controls promotion"
  "config/verification-doctrine.md|a retraction is a record"
  "docs/conventions.md|git ls-files"
  "docs/conventions.md|pull-request only"
)

findings=0
for entry in "${rules[@]}"; do
  owner="${entry%%|*}"; phrase="${entry#*|}"
  while IFS= read -r hit; do
    f="${hit%%:*}"
    [ "$f" = "$owner" ] && continue
    case "$f" in
      docs/*|CHARTER.md|CHANGELOG.md|README.md|SECURITY.md|config/*) continue ;;  # descriptive, not normative
      scripts/check-instructions.sh) continue ;;
    esac
    line="${hit#*:}"; line="${line#*:}"
    # USING a term is not RESTATING its rule. `[NEEDS-SOURCE]` appearing in a writer's
    # instructions is that writer doing its job; a sentence saying what [NEEDS-SOURCE] MEANS is
    # a second definition. Only a normative sentence about the owned concept is a finding: the
    # first version of this check flagged fifteen lines of which almost all were ordinary use,
    # and an advisory gate that is mostly wrong is one people stop reading (TK-062).
    case "$line" in
      *must*|*Must*|*MUST*|*never*|*Never*|*NEVER*|*always*|*Always*|*ALWAYS*|*"do not"*|*"Do not"*) ;;
      *) continue ;;
    esac
    # A line that points AT the owner is the behaviour we want, not a finding.
    case "$line" in *"$owner"*) continue ;; esac
    # A modal inside a backticked span is the marker's own template text, not a rule being
    # restated: `[NEEDS-SOURCE: what must be verified]` is the placeholder, not a second
    # definition of it. Strip code spans before deciding.
    stripped="$(printf '%s' "$line" | sed 's/`[^`]*`//g')"
    case "$stripped" in
      *must*|*Must*|*MUST*|*never*|*Never*|*NEVER*|*always*|*Always*|*ALWAYS*|*"do not"*|*"Do not"*) ;;
      *) continue ;;
    esac
    sct_warn "restates a rule owned by $owner: $hit"
    sct_note "point at the owner instead of repeating it; these files are read on every run"
    findings=$((findings+1))
  done < <(git grep -n -i -F -- "$phrase" -- "$sk_glob" "$ag_glob" 2>/dev/null | head -20)
done

# STAGED, like the other host-facing gates (TK-058). It blocks in the toolkit, which owns the
# rules being restated and is now clean, and in a host that declares it wants the check. It stays
# advisory in a host that has declared nothing: the rules are ours, and failing somebody's build
# over our vocabulary is how an inherited gate gets deleted rather than adopted.
blocking=1
[ "$root" = "$(sct_home)" ] || grep -q '^[[:space:]]*enforce_instruction_ownership:[[:space:]]*true' "$root/.claude/profile.yaml" 2>/dev/null || blocking=0

[ "$quiet" -eq 0 ] && [ "$findings" -eq 0 ] && printf 'check-instructions: no restated fleet rules found in tool files\n'
if [ "$findings" -gt 0 ]; then
  if [ "$blocking" -eq 1 ]; then
    printf 'check-instructions: %d finding(s)\n' "$findings" >&2
    exit 1
  fi
  printf 'check-instructions: %d advisory finding(s)\n' "$findings" >&2
fi
exit 0
