#!/usr/bin/env bash
# Identity guard (Goals G62, G63; TK-017).
#
# THE PROBLEM. This machine carries more than one forge account, more than one SSH key, and a
# global git identity that every fresh clone silently inherits. Nothing checked that the
# identity a repository is using is the identity it is supposed to use. The failure is quiet and
# it is discovered by someone else, later, in a client's history.
#
# WHY THE FORGE ACCOUNT NEEDS ITS OWN CHECK. `gh`'s active account is GLOBAL MUTABLE STATE
# shared by every session on the machine. A second session switching accounts changes the ground
# under this one with no signal. So the account is verified immediately before the operation
# that uses it, never once at the start, and a mismatch blocks rather than warns.
#
# DEGRADATION. If `gh` is absent the account check cannot run: it says so and continues. A check
# that cannot run must never be silently skipped (G44). --strict turns any degradation into a
# failure, and CI runs strict.
#
# Usage: identity-guard.sh [--check] [--strict] [--quiet]
# Exit:  0 identity matches (or only degradations), 1 mismatch, 2 environment error.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

strict=0; quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check|--quiet) [ "$1" = "--quiet" ] && quiet=1; shift ;;
    --strict) strict=1; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "identity-guard: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

root="$(sct_root)" || exit 2
profile="$root/.claude/profile.yaml"
blocks=0; degraded=0

if [ ! -r "$profile" ]; then
  # AN UNDECLARED IDENTITY IS NORMALLY A WARNING, so adopting the toolkit never breaks a
  # repository on day one. But there is one case where "nothing can be verified" is not an
  # acceptable answer: a remote pointing at a NON-CANONICAL host. Such a host is an ~/.ssh/config
  # alias, and an alias exists for exactly one reason -- to select a different key, meaning a
  # different account. So the repository is known to be in multi-account territory while
  # simultaneously declining to say which account it wants. That is the precise condition under
  # which a push silently goes out as the wrong person. It has been observed in the wild: a
  # repository belonging to an organisation, reached over a host alias, carrying no profile at
  # all, and sailing through this guard at exit 0 with nothing checked.
  undeclared_remote="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
  undeclared_host="$(printf '%s' "$undeclared_remote" | sed -E 's#^ssh://##; s#^https?://##; s#^[^@]*@##; s#[:/].*$##')"
  case "$undeclared_host" in
    ""|github.com|gitlab.com|bitbucket.org|codeberg.org|git.sr.ht)
      sct_warn "no repository profile: identity is undeclared, so nothing can be verified"
      sct_note "run 'sct init' to declare it"
      [ "$strict" -eq 1 ] && exit 1
      exit 0 ;;
    *)
      sct_block "no repository profile, and the remote uses the host alias '$undeclared_host'"
      sct_note "an ssh alias selects a different key, so this repository is deliberately not on the"
      sct_note "default account -- but it does not say which account it IS. That is the exact shape"
      sct_note "of a push that goes out as the wrong person, silently."
      sct_note "fix: run 'sct init' here and declare identity.account and identity.ssh_alias"
      printf 'identity-guard: 1 mismatch(es). Operation refused.\n' >&2
      exit 1 ;;
  esac
fi

want_email="$(sct_yaml_get "$profile" identity.email)"
want_name="$(sct_yaml_get "$profile" identity.name)"
want_key="$(sct_yaml_get "$profile" identity.signing_key)"
want_account="$(sct_yaml_get "$profile" identity.account)"
want_alias="$(sct_yaml_get "$profile" identity.ssh_alias)"

got_email="$(git -C "$root" config --get user.email || true)"
got_name="$(git -C "$root" config --get user.name || true)"
got_key="$(git -C "$root" config --get user.signingkey || true)"
got_remote="$(git -C "$root" remote get-url origin 2>/dev/null || true)"

check() { # want got label remedy
  [ -z "$1" ] && return 0
  [ "$1" = "$2" ] && return 0
  sct_block "$3 mismatch: repository declares '$1', git is using '${2:-<unset>}'"
  sct_note "fix: $4"
  blocks=$((blocks+1))
}

check "$want_email" "$got_email" "git email"   "git -C '$root' config user.email '$want_email'"
check "$want_name"  "$got_name"  "git name"    "git -C '$root' config user.name '$want_name'"
# Signing keys compare by SUFFIX. A long key id is the tail of the fingerprint and identifies
# the same key, so a profile holding either form must match a git config holding either form.
if [ -n "$want_key" ]; then
  case "$got_key" in
    *"$want_key") ;;
    "")  sct_block "signing key mismatch: repository declares '$want_key', git has none"
         sct_note "fix: git -C '$root' config user.signingkey '$want_key'"; blocks=$((blocks+1)) ;;
    *)   case "$want_key" in
           *"$got_key") ;;
           *) sct_block "signing key mismatch: repository declares '$want_key', git is using '$got_key'"
              sct_note "fix: git -C '$root' config user.signingkey '$want_key'"; blocks=$((blocks+1)) ;;
         esac ;;
  esac
fi

# The SSH alias decides which key authenticates the push. A remote on the default host with a
# declared alias means the push will go out as the wrong user, or fail confusingly.
if [ -n "$want_alias" ] && [ -n "$got_remote" ]; then
  case "$got_remote" in
    *"$want_alias"*) ;;
    *) sct_block "remote does not use the declared SSH alias '$want_alias': $got_remote"
       sct_note "fix: git -C '$root' remote set-url origin ${want_alias}:<owner>/<repo>.git"
       blocks=$((blocks+1)) ;;
  esac
fi

# EFFECTIVE SSH IDENTITY. Checking the alias in the remote URL is not enough: it says which
# host block ssh will read, not which key ssh will actually offer. With several accounts on one
# machine and a key in the agent, ssh offers the agent's key first and the forge accepts it, so
# a remote that looks right authenticates as the wrong person. That happened here (TK-041), and
# the symptom was "Repository not found" on the operator's own repository.
#
# Only for ssh remotes, only when an account is declared, and it degrades rather than blocking
# when ssh is unavailable or the network is not there: a guard that fails closed on a flaky
# network is a guard people disable.
if [ -n "$want_account" ] && [ -n "$got_remote" ] && sct_have ssh; then
  case "$got_remote" in
    git@*|ssh://*)
      ssh_host="$(printf '%s' "$got_remote" | sed -E 's#^ssh://##; s#^git@##; s#[:/].*$##')"
      whoami_line="$(ssh -T -o BatchMode=yes -o ConnectTimeout=6 "git@$ssh_host" 2>&1 | head -1 || true)"
      case "$whoami_line" in
        Hi\ *)
          ssh_user="$(printf '%s' "$whoami_line" | sed -E 's/^Hi ([^!]+)!.*/\1/')"
          if [ "$ssh_user" != "$want_account" ]; then
            sct_block "ssh authenticates as '$ssh_user', but this repository declares '$want_account'"
            sct_note "the agent's key is offered before the host block's IdentityFile."
            sct_note "fix: add 'IdentitiesOnly yes' to the '$ssh_host' block in ~/.ssh/config"
            blocks=$((blocks+1))
          fi
          ;;
        *) sct_warn "could not determine the ssh identity for $ssh_host: check DEGRADED TO OFF"
           degraded=$((degraded+1)) ;;
      esac
      ;;
  esac
fi

# Forge account: global mutable state, so verified here rather than trusted.
if [ -n "$want_account" ]; then
  if ! sct_have gh; then
    sct_warn "gh is not installed: forge-account check DEGRADED TO OFF"
    degraded=$((degraded+1))
  else
    # EFFECTIVE FORGE IDENTITY, NOT THE LABEL (TK-104, 2026-09-01).
    #
    # This used to parse the active account out of `gh auth status` and compare that. It was the
    # same mistake the ssh check above already refuses to make: reading local configuration and
    # calling it identity. `gh auth switch` moves the label in `gh auth status` WITHOUT moving
    # the credential when the accounts share a keyring slot, so the label and the account the
    # forge actually sees drift apart. Verified here on 2026-09-01: switching to the second
    # account reported success, the label changed, and `gh api user` kept returning the first.
    #
    # A guard reading the label therefore fails in both directions. It blocks a correct
    # operation when the label is stale, which is how this was found. Worse, it PASSES while gh
    # acts as the wrong account, which is the failure it exists to prevent.
    #
    # So ask the forge. `gh api user` is the only answer that cannot drift from the credential.
    # The label is still read, but only to describe the drift in the message.
    label="$(gh auth status 2>&1 | awk '
      /account [A-Za-z0-9_-]+/ { for (i=1;i<=NF;i++) if ($i=="account") acct=$(i+1) }
      /Active account: true/   { if (acct!="") { print acct; exit } }
    ')"
    effective="$(gh api user --jq .login 2>/dev/null || true)"

    if [ -z "$effective" ]; then
      # No network, no credential, or a rate limit. Cannot be read as a match OR a mismatch.
      sct_warn "cannot reach the forge to confirm the account: check DEGRADED TO OFF"
      [ -n "$label" ] && sct_note "the local label says '$label', which is not evidence of anything"
      degraded=$((degraded+1))
    elif [ "$effective" != "$want_account" ]; then
      sct_block "forge account mismatch: repository declares '$want_account', gh authenticates as '$effective'"
      if [ -n "$label" ] && [ "$label" != "$effective" ]; then
        sct_note "the label says '$label', so switching accounts will not fix this: the label is already right"
        sct_note "the accounts share one credential. fix: re-authenticate '$want_account' (gh auth login)"
      else
        sct_note "another session may have switched it, and switching it back would break that one:"
        sct_note "the active account is global mutable state shared by every session on this machine."
        sct_note "pin this shell to the declared account instead, leaving the active account alone:"
        sct_note "  export GH_TOKEN=\$(GH_TOKEN= GITHUB_TOKEN= gh auth token --user '$want_account')"
        sct_note "or pin a single call by putting that assignment in front of it. \`ghuse $want_account\` does the same."
      fi
      blocks=$((blocks+1))
    elif [ -n "$label" ] && [ "$label" != "$effective" ]; then
      # Right identity, wrong label. Not a block: the operation will go out as the declared
      # account. Said out loud because the machine is in a state that will mislead the next
      # reader, and every other tool that trusts the label is currently wrong.
      sct_warn "the forge account label ('$label') disagrees with the effective account ('$effective')"
      sct_note "the operation is correct. anything reading 'gh auth status' instead is not."
    fi
  fi
fi

# ---------------------------------------------------------------- profile placement
# THE RULE. A repository profile describes THIS MACHINE's operator: which account signs, which
# key, which email, which ssh alias. In your own repository that is useful documentation and it
# is committed. In somebody else's repository it is your machine's configuration sitting in
# their history, where it will outlive the engagement, and where the next person to clone will
# inherit an identity declaration that is not theirs.
#
# HOW "SOMEBODY ELSE'S" IS DECIDED, WITHOUT NAMING ANYONE. The toolkit ships to more than one
# operator, so it cannot hardcode an account. It compares the remote's OWNER against the account
# the repository declares. `<account>/<repo>` declared as `<account>` is the operator's own
# namespace and the profile is theirs to commit. `<some-org>/<repo>` declared as a second
# account is an organisation the operator merely has an account in: same person, someone else's
# repository, so the profile stays local and gitignored.
if [ -n "$want_account" ] && [ -n "$got_remote" ]; then
  owner="$(printf '%s' "$got_remote" \
           | sed -E 's#^ssh://##; s#^https?://[^/]+/##; s#^[^@]*@[^:/]+[:/]##; s#/.*$##')"
  if [ -n "$owner" ] && [ "$owner" != "$want_account" ]; then
    if git -C "$root" ls-files --error-unmatch .claude/profile.yaml >/dev/null 2>&1; then
      sct_block "the repository profile is TRACKED in '$owner', which is not your namespace ('$want_account')"
      sct_note "it declares your email, signing key and ssh alias into someone else's history."
      sct_note "fix: git -C '$root' rm --cached .claude/profile.yaml"
      sct_note "then add '.claude/profile.yaml' to .gitignore. The file stays; only the tracking goes."
      blocks=$((blocks+1))
    fi
  fi
fi

if [ "$blocks" -gt 0 ]; then
  printf 'identity-guard: %d mismatch(es). Operation refused.\n' "$blocks" >&2
  exit 1
fi
if [ "$degraded" -gt 0 ] && [ "$strict" -eq 1 ]; then
  sct_block "--strict: refusing to pass with $degraded degraded check(s)"
  exit 1
fi
[ "$quiet" -eq 1 ] || [ "$degraded" -gt 0 ] || printf 'identity-guard: identity matches the profile\n'
exit 0
