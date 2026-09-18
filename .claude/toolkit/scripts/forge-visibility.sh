#!/usr/bin/env bash
# Can the active forge account see this repository, and if not, which account can? (Goal G63)
#
# `identity-guard.sh` already verifies that the account declared by THIS repository is the one
# `gh` has active. That is the right check and it is not this one. It binds the account to the
# current repository, while a `gh` command can name ANY repository: `gh api repos/o/n`,
# `gh pr list --repo o/n`, `gh issue view --repo o/n`. Run from repository A against repository
# B, nothing verifies the account can see B.
#
# What makes that dangerous rather than merely inconvenient is the shape of the failure. GitHub
# answers "you cannot see this" and "this does not exist" with the SAME 404, deliberately, so a
# private repository does not leak its existence. Every caller that writes `|| true` therefore
# turns "wrong account" into "absent" silently. It has already produced a wrong tier here
# (TK-071) and, in a session report, a confident claim that an adopted repository was not
# adopted (TK-082).
#
# This resolves the ambiguity the only way it can be resolved: by asking the other authenticated
# accounts. It reads per-account tokens with `gh auth token --user`, which does NOT touch the
# active account. That matters because `gh`'s active account is global mutable state shared with
# every other session on this machine, and a check that switched it to look around would corrupt
# the thing it is inspecting.
#
# Tokens are passed to a single call through the environment and never printed, logged, or
# written anywhere.
#
# Usage: forge-visibility.sh <owner/name> [--quiet]
# Prints one line:
#   visible <account>            the active account can see it
#   wrong-account <account>      it cannot, but <account> can: the caller is using the wrong one
#   unknown                      no authenticated account can see it: absent, or no access at all
#   cannot-check <reason>        gh missing or no accounts: the caller must not infer anything
# Exit: 0 visible, 1 wrong-account, 2 unknown or cannot-check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

slug="${1:-}"; quiet=0; [ "${2:-}" = "--quiet" ] && quiet=1
case "$slug" in
  */*) : ;;
  *) printf 'forge-visibility: need <owner/name>, got %s\n' "${slug:-nothing}" >&2; exit 2 ;;
esac

if ! sct_have gh; then
  printf 'cannot-check gh-absent\n'; exit 2
fi

# THE ACCOUNT THE FORGE SEES, not the one the local label claims (TK-104, 2026-09-01). The label
# in `gh auth status` moves when `gh auth switch` runs; the credential does not always move with
# it. Reporting the label here would name the wrong account in the answer this script exists to
# give. The label is kept only as a fallback for the offline case, where nothing better exists.
active="$(gh api user --jq .login 2>/dev/null || true)"
[ -n "$active" ] || active="$(gh auth status 2>&1 | awk '
  /account [^ ]+/ { for (i = 1; i <= NF; i++) if ($i == "account") last = $(i + 1) }
  /Active account: true/ { print last; exit }')"

if gh api "repos/$slug" --silent >/dev/null 2>&1; then
  printf 'visible %s\n' "${active:-unknown-account}"; exit 0
fi

# It is not visible to the active account. Ask the others before concluding anything.
others="$(gh auth status 2>&1 | awk '
  /account [^ ]+/ { for (i = 1; i <= NF; i++) if ($i == "account") print $(i + 1) }' | sort -u)"
[ -z "$others" ] && { printf 'cannot-check no-accounts\n'; exit 2; }

# WHETHER THE OTHER ACCOUNTS ARE ACTUALLY OTHER (TK-104, 2026-09-01).
#
# This loop rests on `gh auth token --user <acct>` returning THAT account's token. Where the
# accounts share one keyring slot it returns the same token every time, so every probe below
# repeats the call that already failed, and the script concludes "no account can see it" having
# in truth asked one account twice. That is the confidently-wrong 404 reading this file was
# written to abolish, reintroduced one layer down.
#
# So the tokens are compared before they are trusted. A token identical to the active one proves
# nothing about its account and is not counted as a probe. If none of the others turn out to be
# distinguishable, the honest answer is that this cannot be checked, not that the repository is
# absent. Values are compared, never printed.
active_tok="$(gh auth token 2>/dev/null || true)"
found=""; probed=0; indistinct=0
while IFS= read -r acct; do
  [ -n "$acct" ] || continue
  [ "$acct" = "$active" ] && continue
  tok="$(gh auth token --user "$acct" 2>/dev/null)" || continue
  [ -n "$tok" ] || continue
  if [ -n "$active_tok" ] && [ "$tok" = "$active_tok" ]; then indistinct=$((indistinct+1)); continue; fi
  probed=$((probed+1))
  if GH_TOKEN="$tok" gh api "repos/$slug" --silent >/dev/null 2>&1; then found="$acct"; break; fi
done <<< "$others"
unset tok active_tok

if [ -n "$found" ]; then
  printf 'wrong-account %s\n' "$found"
  if [ "$quiet" -eq 0 ]; then
    sct_block "$slug is invisible to the active account '${active:-unknown}', but '$found' can see it"
    sct_note "a 404 here means 'wrong account', not 'does not exist'."
    sct_note "do not switch the active account: it is global and another session may be using it."
    sct_note "pin instead: export GH_TOKEN=\$(GH_TOKEN= GITHUB_TOKEN= gh auth token --user '$found')"
  fi
  exit 1
fi
if [ "$probed" -eq 0 ] && [ "$indistinct" -gt 0 ]; then
  printf 'cannot-check shared-token\n'
  if [ "$quiet" -eq 0 ]; then
    sct_warn "$indistinct other account(s) resolve to the SAME token as '$active': nothing was learned"
    sct_note "'gh auth token --user' is selecting a label, not a credential, so this cannot say"
    sct_note "whether $slug is absent or merely invisible to this one account."
    sct_note "fix: re-authenticate each account into its own credential (gh auth login)."
  fi
  exit 2
fi
printf 'unknown\n'
[ "$quiet" -eq 0 ] && sct_note "$slug is not visible to any authenticated account: absent, or no access"
exit 2
