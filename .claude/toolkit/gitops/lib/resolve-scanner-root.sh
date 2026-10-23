#!/usr/bin/env bash
# resolve-scanner-root.sh - where the canonical forbidden-token scanner's repository is.
#
# WHY THIS IS A FILE. It used to be a function inside the pre-push hook that ended in a guessed
# home-relative path. When the repository it guessed at moved into a group directory, the guess
# pointed at nothing, the hook quietly took its generic gate instead, and nothing said so. A
# location that is not declared is never guessed (G18, TK-121), and a resolver that lives in the
# hook can only be tested by running the whole hook, which needs signing and a remote.
#
# TWO LAYERS, IN THIS ORDER. The first one that answers decides.
#   1. registry  the path registry (`config/projects.json` in the config home), key below.
#   2. variable  SCT_SCANNER_REPO_DIR, read through sc-env from inside the repository being
#                pushed, so process environment, that repository's `.env` and a declared default
#                all count. Declared in `.claude/env.yaml` (G22).
# Registry before variable is the reverse of the accessor's own order and of TK-010. It is
# deliberate: the registry is the single source for cross-project paths, and the variable exists
# for a machine that has no registry (TK-121).
#
# THE ACCESSOR'S FAILURES ARE NOT THIS SCRIPT'S. sc-env exits non-zero when the repository has no
# declaration file and when the variable has no value. Both mean "this layer did not answer".
# Passing its status through would turn "undeclared" into a refusal in every repository that
# declares nothing, which is most of them.
#
# Prints `<directory><TAB><layer>` on success.
# Exit: 0  a declared location, and the scanner is executable there.
#       1  undeclared: neither layer answers. The caller takes its generic gate (TK-027).
#       2  a declared location with no executable scanner. The caller refuses the push: this is
#          the stale-registry case, and it must not be missable.
# GITOPS_ALLOW_NO_SCANNER=1 turns 2 into 1, loudly, for a machine that shares the registry but
# has no checkout of that repository.
#
# Usage: resolve-scanner-root.sh [--root DIR]
set -uo pipefail

REGISTRY_ENTRY="salvador_cloud_site"
VARIABLE="SCT_SCANNER_REPO_DIR"
SCANNER_REL="scripts/lib/scan-forbidden-tokens.sh"

root=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) root="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,33p' "$0"; exit 0 ;;
    *) echo "resolve-scanner-root: unknown arg '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$root" ] || root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

# This script's own physical directory, so the accessor it uses is the one that shipped with it.
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  d="$(cd -P "$(dirname "$src")" && pwd)"; src="$(readlink "$src")"
  case "$src" in /*) ;; *) src="$d/$src" ;; esac
done
here="$(cd -P "$(dirname "$src")" && pwd)"
config_home="${CLAUDE_CONFIG_HOME:-$HOME/.claude}"

expand() { # a leading ~ or $HOME, as a registry or a declaration file writes it
  local p="$1"
  case "$p" in
    "~"|"~/"*) p="$HOME${p#"~"}" ;;
    '$HOME'|'$HOME/'*) p="$HOME${p#'$HOME'}" ;;
  esac
  printf '%s' "$p"
}

dir="" layer=""

# 1. The registry.
cfg="$config_home/config/projects.json"
if [ -r "$cfg" ]; then
  if command -v jq >/dev/null 2>&1; then
    v="$(jq -r --arg k "$REGISTRY_ENTRY" '.projects[$k] // empty' "$cfg" 2>/dev/null || true)"
    [ -n "$v" ] && { dir="$(expand "$v")"; layer="registry"; }
  else
    echo "resolve-scanner-root: jq not found, so the path registry could not be read." >&2
  fi
fi

# 2. The declared variable, through the accessor.
if [ -z "$dir" ] && [ -n "$root" ] && [ -d "$root" ]; then
  for cand in "$here/../../scripts/sc-env" "$config_home/scripts/sc-env"; do
    [ -r "$cand" ] || continue
    v="$( cd "$root" && bash "$cand" get "$VARIABLE" 2>/dev/null )" || v=""
    [ -n "$v" ] && { dir="$(expand "$v")"; layer="variable"; }
    break
  done
fi

if [ -z "$dir" ]; then
  echo "resolve-scanner-root: the canonical token scanner's location is not declared." >&2
  echo "resolve-scanner-root: declare it as '$REGISTRY_ENTRY' under projects in $cfg, or as $VARIABLE in .claude/env.yaml." >&2
  exit 1
fi

if [ ! -x "$dir/$SCANNER_REL" ]; then
  echo "resolve-scanner-root: the $layer says the scanner's repository is $dir, and there is no executable $SCANNER_REL there." >&2
  if [ "${GITOPS_ALLOW_NO_SCANNER:-0}" = "1" ]; then
    echo "resolve-scanner-root: !! GITOPS_ALLOW_NO_SCANNER=1 - continuing WITHOUT the canonical scanner. Fix the $layer entry." >&2
    exit 1
  fi
  echo "resolve-scanner-root: a declared location that points at nothing is a stop, not a fallback. Fix the $layer entry." >&2
  echo "resolve-scanner-root: on a machine with no checkout of that repository: GITOPS_ALLOW_NO_SCANNER=1 git push ..." >&2
  exit 2
fi

printf '%s\t%s\n' "$dir" "$layer"
