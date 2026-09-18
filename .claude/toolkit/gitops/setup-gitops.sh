#!/usr/bin/env bash
# Per-repo gitops installer. Idempotent.
# Usage:
#   setup-gitops.sh <repo-path> [tier]     # tier: public|private (else read registry / gh)
#   setup-gitops.sh --all                  # install across every repo in the registry
#
# Sets core.hooksPath -> ~/.claude/gitops/hooks, records gitops.tier (+ gitops.repocheck)
# in the repo's git config, and verifies signing + gitleaks. SKIPS repos flagged
# self_managed_hooks (e.g. salvador-cloud-site keeps its committed .githooks/).
set -euo pipefail

HOOKS_DIR="$HOME/.claude/gitops/hooks"
REGISTRY="$HOME/.claude/config/gitops-tiers.json"
PROJECTS="$HOME/.claude/config/projects.json"

expand() { local p="$1"; printf '%s' "${p/#\~/$HOME}"; }

registry_get() {  # $1 repo-key, $2 jq-field -> value or empty
  [ -r "$REGISTRY" ] && command -v jq >/dev/null 2>&1 || return 0
  jq -r --arg k "$1" --arg f "$2" '.repos[$k][$f] // empty' "$REGISTRY" 2>/dev/null || true
}

# Exemption is a RECORDED DECISION, not a filesystem accident.
#
# This used to be a hard-coded `case` on $HOME/projects/personal/*, so a repo was
# exempt because of where it sat on disk. Two problems with that, found 2026-08-27:
# anything dropped into that directory became exempt with no record that a choice
# had been made, and the registry advertised an `exempt` array that NOTHING read,
# so the config lied about how the decision was taken.
#
# Now the array is the mechanism. Entries are literal paths or a trailing-* glob,
# `~` is expanded, and an explicitly passed tier still overrides, so a deliberate
# `setup-gitops.sh <repo> private` can always opt a repo back in.
is_exempt() {  # $1 repo-path -> 0 if exempt
  [ -r "$REGISTRY" ] && command -v jq >/dev/null 2>&1 || return 1
  local pat
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    pat="$(expand "$pat")"
    case "$1" in $pat) return 0 ;; esac
  done < <(jq -r '.exempt[]? // empty' "$REGISTRY" 2>/dev/null)
  return 1
}

install_one() {
  local repo tier; repo="$(expand "$1")"; tier="${2:-}"
  if [ ! -d "$repo/.git" ]; then echo "skip (not a git repo): $repo" >&2; return 0; fi

  # Exempt by recorded decision, unless a tier was passed explicitly.
  if [ -z "$tier" ] && is_exempt "$repo"; then
    echo "skip (exempt by registry): $repo"; return 0
  fi

  local key="~/${repo#"$HOME"/}"
  local self_managed; self_managed="$(registry_get "$key" self_managed_hooks)"
  [ -z "$tier" ] && tier="$(registry_get "$key" tier)"
  if [ -z "$tier" ] && command -v gh >/dev/null 2>&1; then
    local slug; slug="$(git -C "$repo" remote get-url origin 2>/dev/null | sed -E 's#.*github.com[:/]##; s#\.git$##' || true)"
    local vis; vis="$(gh repo view "$slug" --json visibility -q .visibility 2>/dev/null || true)"
    case "$vis" in
      PUBLIC) tier=public ;; PRIVATE) tier=private ;;
    esac
    # The same 404 means "invisible to this account" and "does not exist". Say which, rather
    # than falling through to the default as if the forge had answered (TK-082).
    local fv; fv="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/forge-visibility.sh"
    if [ -z "$vis" ] && [ -x "$fv" ]; then
      case "$(bash "$fv" "$slug" --quiet 2>/dev/null)" in
        wrong-account*) echo "warn: cannot read $slug with the active forge account; tier defaulted. Switch accounts and re-run." >&2 ;;
      esac
    fi
  fi
  [ -z "$tier" ] && tier=private

  git -C "$repo" config gitops.tier "$tier"
  local repocheck; repocheck="$(registry_get "$key" repo_check)"
  if [ -n "$repocheck" ]; then git -C "$repo" config gitops.repocheck "$repocheck"; fi

  if [ "$self_managed" = "true" ]; then
    echo "ok ($tier, self-managed hooks — not touching core.hooksPath): $repo"
  else
    git -C "$repo" config core.hooksPath "$HOOKS_DIR"
    echo "linked ($tier) core.hooksPath -> $HOOKS_DIR: $repo"
  fi

  # Signing check (required everywhere)
  if [ "$(git -C "$repo" config --get commit.gpgsign || echo false)" != "true" ] \
     && [ "$(git config --global --get commit.gpgsign || echo false)" != "true" ]; then
    echo "  warn: commit signing not enabled for this repo or globally." >&2
  fi
}

main() {
  chmod +x "$HOOKS_DIR"/* 2>/dev/null || true
  command -v gitleaks >/dev/null 2>&1 || echo "warn: gitleaks not installed (pre-push secret scan will fail closed). brew install gitleaks" >&2

  if [ "${1:-}" = "--all" ]; then
    [ -r "$REGISTRY" ] && command -v jq >/dev/null 2>&1 || { echo "registry/jq unavailable" >&2; exit 2; }
    while IFS= read -r key; do
      case "$key" in "$HOME"/*|"~/"*) install_one "$key" ;; esac   # only local-path keys; gh-slug keys are server-side
    done < <(jq -r '.repos | keys[]' "$REGISTRY")
  elif [ -n "${1:-}" ]; then
    install_one "$1" "${2:-}"
  else
    echo "usage: setup-gitops.sh <repo-path> [tier] | --all" >&2; exit 1
  fi
}
main "$@"
