#!/usr/bin/env bash
# Public-readiness gate (Goal G4, TK-003).
#
# The single control that makes "flip this repository public whenever you like" a true
# statement rather than a hope. It runs on every push and in CI, so the property is maintained
# continuously instead of audited once.
#
# Five checks:
#   1. instance data      - nothing listed in instance-manifest.yaml is tracked, and each entry
#                           is gitignored. BLOCK.
#   2. sensitive tokens   - no token from the external sensitive-token list appears in a tracked
#                           file outside the attribution allowlist. BLOCK.
#   3. identity in logic  - tool logic does not hardcode an identity that belongs in a profile.
#                           BLOCK (it is both a leak and a G18/G36 violation).
#   4. secret-shaped file - no tracked file whose NAME says secret. BLOCK.
#   5. root licence       - a public-tier repository tracks a LICENSE at its root. WARN, and
#                           BLOCK under --strict.
#
# WHERE THE TOKEN LIST LIVES, AND WHY NOT HERE. The list of client names and personal
# identifiers is itself sensitive: committing it to a repository that may be published would
# leak exactly what it exists to protect. So it is read from outside, in this order:
#   1. $SCT_TOKENS_FILE
#   2. <config home>/config/sensitive-tokens.txt
#   3. derived from the instance disclosure registry, if one is readable
# With no list available the check DEGRADES TO A WARNING and says so. It never passes silently:
# a skipped gate nobody was told about is worse than a failed one (G44).
#
# Usage: check-public-ready.sh [--strict] [--quiet]
# Exit:  0 clean (or warnings only), 1 blocking finding, 2 environment error.
set -uo pipefail
# shellcheck source=../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"

strict=0; quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --strict) strict=1; shift ;;
    --quiet) quiet=1; shift ;;
    -h|--help) sed -n '2,28p' "$0"; exit 0 ;;
    *) echo "check-public-ready: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

root="$(sct_root)" || exit 2
cd "$root" || exit 2
blocks=0; warns=0

# Attribution surfaces: an author's name belongs here by design.
attribution_ok() {
  case "$1" in
    LICENSE|README.md|SECURITY.md|CHANGELOG.md|CHARTER.md|.github/CODEOWNERS) return 0 ;;
    docs/decisions/*) return 0 ;;
    *.example) return 0 ;;
    scripts/check-public-ready.sh) return 0 ;;
    *) return 1 ;;
  esac
}

# ---- 1. instance data must not be tracked, and must be gitignored -------------------------
manifest="$root/instance-manifest.yaml"
if [ ! -r "$manifest" ]; then
  # Only the toolkit itself carries an instance inventory; a consuming repository has no
  # instance data to keep out, so there is nothing for this check to compare against. Blocking
  # here failed the gate in every adopting repository (TK-057). The remaining checks still run.
  sct_warn "no instance-manifest.yaml: instance-data check skipped (normal outside the toolkit)"
  warns=$((warns+1))
  [ "$strict" -eq 1 ] && { sct_block "--strict: refusing to pass with the instance-data check skipped"; blocks=$((blocks+1)); }
else
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if git ls-files --error-unmatch "$p" >/dev/null 2>&1; then
      sct_block "instance data is TRACKED: $p"; blocks=$((blocks+1))
    fi
    # A directory entry ends in /; check-ignore handles both.
    if ! git check-ignore -q "$p" 2>/dev/null; then
      sct_block "instance path is not gitignored: $p"; blocks=$((blocks+1))
    fi
  done < <(awk '/^[[:space:]]*-[[:space:]]*path:/ { sub(/^[[:space:]]*-[[:space:]]*path:[[:space:]]*/,""); print }' "$manifest")
fi

# ---- 2. sensitive tokens -------------------------------------------------------------------
tokens_file=""
cfg_home="${CLAUDE_CONFIG_HOME:-$HOME/.claude}"
if [ -n "${SCT_TOKENS_FILE:-}" ] && [ -r "${SCT_TOKENS_FILE}" ]; then
  tokens_file="$SCT_TOKENS_FILE"
elif [ -r "$cfg_home/config/sensitive-tokens.txt" ]; then
  tokens_file="$cfg_home/config/sensitive-tokens.txt"
fi

derived=""
if [ -z "$tokens_file" ] && [ -r "$cfg_home/config/facts/engagements.yaml" ]; then
  derived="$(mktemp)"
  # Entity ids and always-forbidden tokens, nothing else. Never printed.
  awk '/^[[:space:]]*-[[:space:]]*id:/ { sub(/^[[:space:]]*-[[:space:]]*id:[[:space:]]*/,""); print }
       /^[[:space:]]*-[[:space:]]+[A-Za-z0-9_]+[[:space:]]*$/ { gsub(/^[[:space:]]*-[[:space:]]*/,""); print }' \
       "$cfg_home/config/facts/engagements.yaml" 2>/dev/null | sort -u > "$derived"
  [ -s "$derived" ] && tokens_file="$derived"
fi

if [ -z "$tokens_file" ]; then
  sct_warn "no sensitive-token list available: token scanning DEGRADED TO OFF"
  sct_note "provide one via SCT_TOKENS_FILE or $cfg_home/config/sensitive-tokens.txt"
  warns=$((warns+1))
  [ "$strict" -eq 1 ] && { sct_block "--strict: refusing to pass with token scanning off"; blocks=$((blocks+1)); }
else
  while IFS= read -r tok; do
    tok="${tok%%#*}"; tok="$(printf '%s' "$tok" | tr -d '[:space:]')"
    [ -n "$tok" ] || continue
    while IFS= read -r hit; do
      f="${hit%%:*}"
      attribution_ok "$f" && continue
      sct_block "sensitive token in tracked file: $f (token withheld from this output)"
      blocks=$((blocks+1))
    done < <(git grep -I -l -i -F -- "$tok" 2>/dev/null | sed 's/$/:/')
  done < "$tokens_file"
fi
[ -n "$derived" ] && rm -f "$derived"

# ---- 3. identity hardcoded in tool logic ---------------------------------------------------
# An identity in a generic tool is a portability bug before it is a privacy one: the tool
# should be reading it from the repository profile (G36, G62).
# Well-known non-identity addresses: constants a tool legitimately writes, not an operator's
# identity. Kept as an explicit list, so adding one is a visible decision.
non_identity() {
  case "$1" in
    *noreply@anthropic.com*|*noreply@github.com*|*example.com*|*@example.org*) return 0 ;;
    # An ssh remote is a URL, not an identity: 'git@host' matches the email pattern but names
    # nobody. Without this the gate flags its own documentation of how remotes are parsed.
    *git@*:*|*git@github.com*|*git@gitlab.com*|*git@bitbucket.org*) return 0 ;;
    *) return 1 ;;
  esac
}
while IFS= read -r hit; do
  f="${hit%%:*}"
  attribution_ok "$f" && continue
  # Re-read the matching lines: a file is only a finding if a match is a real identity.
  real=0
  while IFS= read -r line; do
    non_identity "$line" || real=1
  done < <(git grep -h -E -- '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' -- "$f" 2>/dev/null)
  [ "$real" -eq 0 ] && continue
  case "$f" in
    skills/*|agents/*|bin/*|lib/*|gitops/*|hooks/*|scripts/*)
      sct_block "identity hardcoded in tool logic: $f (belongs in the repository profile)"
      blocks=$((blocks+1)) ;;
  esac
done < <(git grep -I -l -E -- '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 2>/dev/null | sed 's/$/:/')

# ---- 4. secret-shaped tracked files ---------------------------------------------------------
while IFS= read -r f; do
  case "$f" in
    # Vendored toolkit content is gated in the toolkit's own CI. Re-judging it here flagged the
    # toolkit's own secret ACCESSOR as a secret, in a repository that merely installed it.
    .claude/toolkit/*) continue ;;
    *.example|*secrets-registry.yaml*|*sensitive-tokens*|scripts/sc-secret|scripts/check-public-ready.sh) continue ;;
    .env|*/.env|*secret*|*token*|*.key|*.tfvars|id_*|*/id_*)
      sct_block "secret-shaped file is tracked: $f"; blocks=$((blocks+1)) ;;
  esac
done < <(sct_tracked "$root")

# ---- 5. a public-tier repository carries a root LICENSE -------------------------------------
# Published code with no licence is all-rights-reserved by default, which is rarely what the
# author meant and never what a reader can tell. The documentation standard already requires a
# public repository to LINK its LICENSE (config/docs/standard.md, security and licence
# pointers); nothing checked the file was there, and this gate passed on a public-tier repository
# that had none.
#
# TIER comes from the repository profile first and git config second. The profile is committed,
# so it is the one a CI checkout can read; git config is per-clone and absent there. A
# private-tier repository is not asked: no licence is a legitimate state for code nobody
# receives. TRACKED, not merely present on disk, because publication ships commits.
tier="$(sct_yaml_get "$root/.claude/profile.yaml" gitops.tier 2>/dev/null || true)"
[ -n "$tier" ] || tier="$(git -C "$root" config --get gitops.tier 2>/dev/null || true)"
if [ "$tier" = "public" ]; then
  # Counted, not `grep -q`: under pipefail a -q that exits on its first match can SIGPIPE the
  # listing and turn a found licence into a failed pipeline in a large repository.
  lic="$(sct_tracked "$root" | grep -ciE '^(LICEN[SC]E|COPYING|UNLICENSE)([.-][^/]*)?$' || true)"
  if [ "${lic:-0}" -eq 0 ]; then
    sct_warn "public-tier repository tracks no root LICENSE: published without one, the code is all rights reserved"
    sct_note "add a LICENSE at the repository root and link it from the README (config/docs/standard.md)"
    warns=$((warns+1))
    [ "$strict" -eq 1 ] && { sct_block "--strict: refusing to pass a public-tier repository with no root LICENSE"; blocks=$((blocks+1)); }
  fi
fi

if [ "$blocks" -gt 0 ]; then
  printf 'check-public-ready: %d blocking finding(s), %d warning(s)\n' "$blocks" "$warns" >&2
  exit 1
fi
[ "$quiet" -eq 1 ] || [ "$warns" -gt 0 ] || printf 'check-public-ready: clean\n'
exit 0
