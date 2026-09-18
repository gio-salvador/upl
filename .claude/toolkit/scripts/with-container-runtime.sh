#!/usr/bin/env bash
# Run a command with a container runtime available, and leave the machine as it was found.
#
# WHY THIS EXISTS. Some repositories run their own gates in containers: one repository's
# pre-commit is a containerised lint. With the runtime down, its commit fails, and any tool
# operating on that repository fails with it (TK-053 was first seen this way).
#
# Adoption does not start a virtual machine on its own. That would be a surprising side effect of
# a command whose job is to write two files, and a tool that silently boots infrastructure is a
# tool people stop trusting with anything. So this is a separate, explicit wrapper the operator
# composes when they want it:
#
#   with-container-runtime.sh sct adopt ~/projects/some-repo
#
# THE CONTRACT: if the runtime was already up, this changes nothing and leaves it up. If it was
# down, this starts it, runs the command, and stops it again, whatever the command's exit status.
# The command's exit status is passed through untouched.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

[ $# -gt 0 ] || { echo "usage: with-container-runtime.sh <command> [args...]" >&2; exit 2; }

runtime_up() { docker info >/dev/null 2>&1; }

started_by_us=0
cleanup() {
  if [ "$started_by_us" -eq 1 ]; then
    sct_note "stopping the container runtime (it was not running before)"
    colima stop >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

if runtime_up; then
  sct_note "container runtime already running; leaving it up afterwards"
else
  sct_have colima || { sct_block "the container runtime is down and colima is not installed"; exit 2; }
  sct_note "starting the container runtime"
  if ! colima start >/dev/null 2>&1; then
    sct_block "could not start the container runtime; the command was not run"
    exit 2
  fi
  # Starting the VM is not the same as the daemon accepting connections.
  for _ in 1 2 3 4 5 6 7 8 9 10; do runtime_up && break; sleep 3; done
  if ! runtime_up; then
    sct_block "the runtime started but the daemon never accepted connections; the command was not run"
    started_by_us=1
    exit 2
  fi
  started_by_us=1
fi

"$@"
rc=$?
exit "$rc"
