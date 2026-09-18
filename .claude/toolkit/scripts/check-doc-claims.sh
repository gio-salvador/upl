#!/usr/bin/env bash
# Docs describe, source defines: when they disagree the docs are wrong (Goal G15).
#
# check-docs.sh already resolves links between documents. Nothing checked the claims documents
# make ABOUT the repository, which is where drift actually happens: a path that moved, a
# subcommand that was renamed, a script that was deleted, a flag spelled the way it used to be.
# The doc keeps saying the old thing and reads as authoritative, because prose has no compiler.
#
# This gate reads what the docs assert and holds it against the source (TK-078):
#   1. a code span naming a path in this repository must resolve to a tracked file or directory
#   2. `sct <subcommand>` must be a subcommand, read from the dispatch itself so the list cannot
#      drift from the code the way a hand-kept list would
#   3. a code span naming a script or schema file must be a file that exists
#
# It judges only spans that unambiguously CLAIM something: anything holding a placeholder, a
# glob, a shell variable or whitespace is prose and is skipped, as is every fenced block, which
# holds examples and transcripts rather than assertions. A gate with false positives gets
# disabled, so it would rather miss a claim than invent one.
#
# Usage: check-doc-claims.sh [--quiet]. Exit 0 clean, 1 finding, 2 cannot check.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
quiet=0; [ "${1:-}" = "--quiet" ] && quiet=1
root="$(sct_root)" || exit 2
home="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$home/scripts/check-doc-claims.py" "$root" "$quiet"
