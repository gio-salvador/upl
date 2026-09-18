#!/usr/bin/env bash
# Every tool declares what it depends on, and the declaration is held against the tree (TK-099).
#
# The relationships between tools were prose until now: which agents a skill spawns, which sibling
# skills it invokes, which config it reads, what the host must provide. Prose cannot be closed
# over, so nothing could answer "what does importing this tool actually pull in", which is what
# blocks a selective import into a repository we do not own (docs/plans/import-tools.md).
#
# The declaration earns trust by being falsifiable: declared skills, agents and toolkit paths must
# exist, and an `instance:` path must NOT exist here, because a path the toolkit ships travels with
# a vendored copy and is therefore not one operator's data. Coverage is reported, not required,
# while the backfill is in progress.
#
# Usage: check-requires.sh [--quiet]. Exit 0 clean, 1 finding, 2 cannot check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
home="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$home/scripts/check-requires.py" "$root" "$quiet"
