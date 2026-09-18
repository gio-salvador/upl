#!/usr/bin/env bash
# PreToolUse guard: a repository-changing git operation goes through the skill that owns it.
#
# THE PROBLEM THIS EXISTS FOR. This toolkit ships skills that open, land and review pull
# requests. Those skills carry the parts a raw command has no way to carry: the manifest's
# pre-steps, the repository's own pre-PR gate, the declared commit trailer, the tier checks. None
# of that is optional, and none of it happens when somebody types `gh pr create` instead.
#
# It is not hypothetical. Nineteen pull requests were opened in this repository with a raw
# `gh pr create`, bypassing `sc-open-pr` every time, and no gate noticed (TK-051). A rule that
# lives only in prose is a rule that holds until the first time somebody is in a hurry.
#
# HOW A SKILL GETS THROUGH. The guard reads the command text, so a skill declares itself in the
# command line: `SCT_VIA=sc-open-pr gh pr create ...`. An environment variable set in an earlier
# tool call cannot reach this hook, and a marker file would be state to clean up, so the
# declaration rides on the invocation where it is visible in the transcript.
#
# That makes it bypassable by anyone who types the prefix. That is deliberate. This guard exists
# to stop the ACCIDENTAL bypass, which is the one that actually happened; a deliberate override
# is a considered act that appears in the record, exactly like GITOPS_ALLOW_MAIN.
#
# WHAT IS NOT DENIED. Every read: `gh pr list`, `view`, `diff`, `checks`, `status`. Every local
# git operation: commit, branch, worktree, push. Those are the skills' own building blocks, and
# a guard that blocked them would block the skills it is protecting.
#
# Hook input  (stdin, JSON): { "tool_name": "...", "tool_input": { ... } }
# Hook output (stdout, JSON): a PreToolUse permissionDecision, or nothing.
# Exit 0 with no output = passthrough.
#
# FAIL CLOSED on anything it cannot read, for the same reason as its sibling guard: a guard that
# opens when it breaks is not a guard.
set -euo pipefail

# THE REASON STRING IS NOT ALWAYS THIS FILE'S OWN PROSE. It can carry a value read from the
# repository or from the tool call -- an account name out of a profile, a tool suffix off the
# invocation -- and a backslash, a quote or a control character in one of those turns the hand-
# built JSON into malformed JSON. The caller then cannot read the decision, so a DENY that was
# correctly reached is a deny that does not arrive. Let jq do the escaping; it is already a hard
# dependency of both guards.
emit() {
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg d "$1" --arg r "$2" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  else
    # jq missing is itself one of the deny paths, and it is reached BEFORE any dynamic value is
    # read, so the only text arriving here is this guard's own static prose. Quote-strip anyway,
    # with bash parameter expansion rather than `tr`: this branch runs precisely when the PATH is
    # impoverished, and a fallback that shells out to another tool emits empty strings instead of
    # a decision when that tool is missing too. It did exactly that when first written.
    local d="${1//[\\\"]/}" r="${2//[\\\"]/}"
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$d" "$r"
  fi
  exit 0
}
deny() { emit "deny" "$1"; }
trap 'emit "deny" "gitops-via-skills guard crashed (fail-closed). Nothing ran. Use the skill that owns the operation."' ERR

RULE="Declared in the toolkit conventions: a repository-changing git operation goes through the skill that owns it."

payload=$(cat 2>/dev/null || true)
[ -n "$payload" ] || deny "Refused: the gitops-via-skills guard received no input and cannot tell what was asked for, so it denies. $RULE"
command -v jq >/dev/null 2>&1 || deny "Refused: the gitops-via-skills guard needs jq to read its input and jq is missing, so it denies rather than guessing. $RULE"
jq -e 'type == "object"' >/dev/null 2>&1 <<<"$payload" || deny "Refused: the gitops-via-skills guard could not parse its input, so it denies. $RULE"

tool=$(jq -r '.tool_name // ""' <<<"$payload")
[ -n "$tool" ] || deny "Refused: the gitops-via-skills guard received a tool call with no tool name, so it denies. $RULE"

# Only shell invocations carry these commands.
case "${tool##*__}" in Bash|bash) ;; *) exit 0 ;; esac

cmd=$(jq -r '.tool_input.command // ""' <<<"$payload")
[ -n "$cmd" ] || exit 0

# Match a real invocation at a command position, so prose, a heredoc or a comment that merely
# mentions the command is not an invocation.
#
# PREFIXES ARE PART OF THE COMMAND POSITION, and leaving them out made this gate
# skippable without any declaration at all: `FOO=bar gh pr create` and
# `sudo gh pr create` both matched nothing and sailed through, because after an
# assignment or `sudo` there is no separator left for the anchor to find. A bare
# NAME=value prefix is how a shell accepts per-command environment, so it is as
# ordinary as the plain form.
PREFIX='((sudo|env)[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*'
invokes() { # <regex tail after `gh `>
  printf '%s' "$cmd" | grep -Eq "(^|[;&|]|&&|\|\||\bthen\b|\bdo\b|\(|\`|\\\$\()[[:space:]]*${PREFIX}gh[[:space:]]+$1"
}

# ---------------------------------------------------------------- forge account
# THE PROBLEM. `gh` has ONE active account for the whole machine and it is chosen by
# ~/.config/gh/hosts.yml, not by the repository you are standing in. In a repository belonging to
# the other account every unpinned `gh` call runs as the wrong person. Against a private repository
# that surfaces as `404` for a single fetch and, far worse, as `Could not resolve to a Repository`
# or an EMPTY LIST for a query -- which reads as "nothing to do" rather than "you are the wrong
# person". A PR-triage loop that sees an empty list reports success and stops.
#
# WHY HERE AND NOT IN EACH SKILL. The skills invoke `gh` in about twenty-five places and an agent
# invents more. Documenting the pin in each one leaves every undocumented call broken, which is
# the TK-051 lesson: a rule that lives only in prose holds until the first time somebody is in a
# hurry. So it is enforced once, at the point of use, and it covers calls nobody wrote down.
#
# WHY THIS RUNS BEFORE THE SCT_VIA PASSTHROUGH. A skill declaring itself is exactly the case that
# needs the pin: the skills are the unpinned callers this exists to fix. Declaring which skill you
# are says nothing about which account you are.
#
# WHY THE LABEL AND NOT THE FORGE. Asking the forge (`gh api user`) is the only answer that cannot
# drift from the credential, but it is a network round trip on EVERY Bash tool call. So this reads
# the local label, which is free, and catches the common case: the declared account and the active
# account plainly disagree. The authoritative forge-truth check still runs in identity-guard at
# push time, where one round trip is affordable. Cheap check early, authoritative check at the
# gate; neither replaces the other.
#
# The pin must ride on the invocation because a shell variable exported in one tool call does not
# reach the next -- the same reason SCT_VIA rides on the command line.
# A command position here must also allow a leading environment assignment, because the invocation
# that most needs checking wears one: `SCT_VIA=sc-open-pr gh pr create`. `invokes` deliberately
# does not allow it -- the gates below it never see an SCT_VIA command -- so this needs its own.
invokes_gh() { # any `gh` invocation, with or without env-assignment prefixes; <regex tail or ''>
  printf '%s' "$cmd" | grep -Eq "(^|[;&|]|&&|\|\||\bthen\b|\bdo\b|\(|\`|\\\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*gh[[:space:]]+$1"
}

if invokes_gh '' && ! printf '%s' "$cmd" | grep -Eq '(GH_TOKEN|GITHUB_TOKEN)='; then
  # `gh auth ...` is how you inspect and mint the pin. Pinning it would be circular.
  if ! invokes_gh 'auth\b'; then
    # WHICH REPOSITORY IS THIS CALL ACTUALLY FOR? The hook runs before the command does, so the
    # working directory is wherever the CALLER happens to be standing, which is not necessarily
    # where the command will run. `cd <repo> && gh ...` is the ordinary shape of an agent's
    # invocation, and judging it against the previous command's directory denies a correct call
    # while naming the wrong repository in the refusal. That happened twice within an hour of
    # this gate shipping, to the author of the gate, which is how a guard earns a reputation for
    # crying wolf and then gets switched off (the TK-051 lesson, from the other direction).
    # So an explicit `cd` at a command position wins over the ambient directory.
    # A `cd` ANYWHERE before the gh call, not merely a leading one. `git fetch && cd repo && gh`
    # and `set -e; cd repo; gh` are as ordinary as `cd repo && gh`, and an earlier version of this
    # that only understood a leading `cd` still refused both. Walk the command's segments in
    # order, remember the most recent `cd` target, and stop at the first `gh` invocation -- a `cd`
    # AFTER the gh call says nothing about where the gh call runs.
    _cd=$(printf '%s' "$cmd" | awk '
      BEGIN { RS="\n"; }
      {
        n = split($0, seg, /&&|\|\||[;|]/)
        for (i = 1; i <= n; i++) {
          s = seg[i]
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
          # Skip leading VAR=value assignments so `SCT_VIA=x gh ...` is seen as a gh call.
          while (match(s, /^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+/)) s = substr(s, RLENGTH + 1)
          if (s ~ /^gh[[:space:]]/) { print target; exit }
          if (match(s, /^cd[[:space:]]+/)) {
            t = substr(s, RLENGTH + 1)
            sub(/[[:space:]].*$/, "", t)
            gsub(/^"|"$|^'"'"'|'"'"'$/, "", t)
            target = t
          }
        }
      }
      END { print target }' | head -1)
    case "$_cd" in "~"/*) _cd="$HOME/${_cd#"~"/}" ;; "~") _cd="$HOME" ;; esac
    if [ -n "$_cd" ] && [ -d "$_cd" ]; then
      _root=$(git -C "$_cd" rev-parse --show-toplevel 2>/dev/null || true)
    else
      _root=""
    fi
    [ -n "$_root" ] || _root=$(git rev-parse --show-toplevel 2>/dev/null || true)
    _profile="${_root:+$_root/.claude/profile.yaml}"
    if [ -n "$_profile" ] && [ -r "$_profile" ]; then
      # Deliberately not sct_yaml_get: this hook stays dependency-free so it cannot fail closed
      # on a repository that has not vendored lib/.
      # Every assignment ends `|| true`. `set -o pipefail` plus the fail-closed ERR trap means a
      # single non-zero anywhere in these pipelines would deny EVERY Bash call on the machine,
      # which is a far worse failure than the one this block prevents.
      _want=$( { sed -n '/^identity:/,/^[^[:space:]]/p' "$_profile" \
              | sed -n 's/^[[:space:]]*account:[[:space:]]*//p' | tr -d "\"' " | head -1; } 2>/dev/null || true)
      _active=$( { sed -n 's/^[[:space:]]*user:[[:space:]]*//p' "${GH_CONFIG_DIR:-$HOME/.config/gh}/hosts.yml" | tr -d "\"' " | tail -1; } 2>/dev/null || true)
      if [ -n "$_want" ] && [ -n "$_active" ] && [ "$_want" != "$_active" ]; then
        deny "Refused: this repository declares the forge account '$_want', but gh's active account is '$_active', so this call would run as the wrong person. Against a private repository that returns 404, or an empty list that reads as 'nothing to do'. Do NOT run 'gh auth switch': the active account is global mutable state shared by every session on this machine, and moving it breaks whatever else is running. Pin this one call instead, on the invocation itself (an export cannot reach the next tool call): GH_TOKEN=\$(GH_TOKEN= GITHUB_TOKEN= gh auth token --user $_want) <your gh command>"
      fi
    fi
  fi
fi

# A skill declaring itself on the invocation passes through.
#
# THE DECLARATION MUST LOOK LIKE A DECLARATION. This was `case "$cmd" in *SCT_VIA=*)`,
# a substring match anywhere in the command with no validation of the value, so every
# one of these passed:
#
#   SCT_VIA= gh pr create ...                  (empty value)
#   SCT_VIA=lol gh pr create ...               (any value at all)
#   gh pr merge 1 --squash # SCT_VIA=x         (inside a comment)
#   echo SCT_VIA=x && gh pr merge 1 --squash   (a different command entirely)
#
# It is an honour-system control either way: the caller composes the command, so no
# hook can prove a skill really ran. But there is a wide gap between "the skill says
# so" and "any command containing eleven characters", and the second is what shipped.
# Nine pull requests were opened against a consuming repository on 2026-09-01 by an
# agent that declared itself and was not the skill; the shortcut was invisible
# afterwards because nothing recorded it. Hence both halves below: the declaration has
# to be structurally real, and every use of it is written down.
#
# Only the skills that OWN the pull-request lifecycle may declare. Anything else that
# needs a PR defers to sc-open-pr, which is already how the other skills are written,
# so this list stays short by design rather than growing one project skill at a time.
SCT_VIA_SKILLS='sc-open-pr|sc-land-pr|sc-split-to-prs'
DECLARED_RE="(^|[;&|]|&&|\|\||\bthen\b|\bdo\b|\(|\`|\\\$\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*SCT_VIA=(${SCT_VIA_SKILLS})[[:space:]]+${PREFIX}gh[[:space:]]"

if printf '%s' "$cmd" | grep -Eq "$DECLARED_RE"; then
  # Record it. A declaration that no skill run accounts for should be findable
  # later; that is the whole value of an honour-system control being logged.
  # Never let logging failure change the decision — a full disk must not turn a
  # permitted call into a denied one, nor the reverse.
  {
    _via=$(printf '%s' "$cmd" | grep -Eo "SCT_VIA=(${SCT_VIA_SKILLS})" | head -1 | cut -d= -f2)
    _log="${SCT_LOG_DIR:-$HOME/.claude}/gitops-declarations.log"
    mkdir -p "$(dirname "$_log")" 2>/dev/null &&
      printf '%s\t%s\t%s\t%.200s\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${_via:-unknown}" \
        "$(git rev-parse --show-toplevel 2>/dev/null || echo '-')" "$cmd" >> "$_log"
  } 2>/dev/null || true
  exit 0
fi

if invokes 'pr[[:space:]]+create'; then
  deny "Refused: 'gh pr create' skips everything sc-open-pr carries: the manifest's pre_steps (for this repository, sc-docs-sync, so a change and its documentation ship together), the pre-PR gate, and the declared commit trailer. Nineteen PRs were opened this way here and no gate noticed. Use the sc-open-pr skill. If you are sc-open-pr, declare it: SCT_VIA=sc-open-pr gh pr create ... $RULE"
fi
if invokes 'pr[[:space:]]+merge'; then
  deny "Refused: 'gh pr merge' skips sc-land-pr, which confirms merge-readiness against the repository's tier before landing: required checks green, signed, CODEOWNERS satisfied, no conflict. Merging past a failing gate is the one thing that cannot be undone by a later commit. Use the sc-land-pr skill, or declare yourself: SCT_VIA=sc-land-pr gh pr merge ... $RULE"
fi
if invokes 'pr[[:space:]]+(edit|ready|close|reopen)'; then
  deny "Refused: this changes a pull request other people are reading. It belongs to the skill that owns the PR lifecycle (sc-open-pr, sc-land-pr), or to a person. Declare yourself if you are that skill: SCT_VIA=<skill> gh pr ... $RULE"
fi
if invokes 'repo[[:space:]]+(create|delete|archive|edit)'; then
  deny "Refused: creating, deleting, archiving or reconfiguring a repository is not a routine operation and no skill owns it. A person does this deliberately. $RULE"
fi

exit 0
