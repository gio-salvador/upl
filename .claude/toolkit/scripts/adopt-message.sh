#!/usr/bin/env bash
# The adoption commit message, composed from the STAGED DIFF (issue #40).
#
# `sct adopt` wrote one hardcoded message, and it was the message for a FIRST adoption. Run
# against a repository that already carries a vendored copy, which is exactly what --force is
# for, and the commit claimed to add a `.claude/profile.yaml` it never opened.
#
# Unlike a pull request body, which is read for a day, a commit message survives the squash
# merge and becomes the repository's permanent record: what anyone bisecting reads years later.
# A tool that installs itself into other repositories was writing false history into every one
# of them, once per upgrade, and each instance had to be caught by hand at review time.
#
# So the message is DERIVED rather than chosen. It describes the staged diff, which is the only
# thing that cannot be wrong about what the commit does.
#
# Usage: adopt-message.sh <work-tree> <profile> <version>. Prints the message on stdout.
set -uo pipefail
wt="${1:?work tree required}"; profile="${2:?profile required}"; ver="${3:?version required}"

staged="$(git -C "$wt" diff --cached --name-status 2>/dev/null)"

if printf '%s\n' "$staged" | grep -qE '^A[[:space:]]+\.claude/profile\.yaml$'; then
  cat <<EOF
chore(toolkit): adopt salvadorcloud-ai-toolkit $ver

Adds .claude/profile.yaml (this repository's own declarations) and .claude/toolkit.lock
(the pinned toolkit version), plus the vendored $profile profile.

Fields that could not be inferred are listed under \`todo\` in the profile: they are
recorded rather than guessed. Run \`sct validate\` to see them.
EOF
  exit 0
fi

# A refresh. Read the previous version from the ref rather than assuming one: a lockfile that
# cannot be read is reported as unknown, never invented.
prev="$(git -C "$wt" show HEAD:.claude/toolkit.lock 2>/dev/null |
        sed -n 's/^version:[[:space:]]*//p' | tr -d '"'\''' | head -1)"
n="$(printf '%s\n' "$staged" | grep -c '^[A-Z]')" || n=0

if printf '%s\n' "$staged" | grep -qE '^[AM][[:space:]]+\.claude/profile\.yaml$'; then
  prof="This repository's .claude/profile.yaml is modified by this commit; review it."
else
  prof="This repository's .claude/profile.yaml is untouched: a refresh re-vendors the toolkit,
it does not rewrite the declarations this repository made."
fi

printf 'chore(toolkit): refresh salvadorcloud-ai-toolkit to %s\n\n' "$ver"
if [ -n "$prev" ]; then
  printf 'Re-vendors the %s profile and moves .claude/toolkit.lock from %s to %s.\n' "$profile" "$prev" "$ver"
else
  printf 'Re-vendors the %s profile and updates .claude/toolkit.lock (the previous version\ncould not be read).\n' "$profile"
fi
printf '%s file(s) changed.\n\n%s\n' "$n" "$prof"
