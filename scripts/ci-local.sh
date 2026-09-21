#!/usr/bin/env bash
# The CI of this repository, run on this machine. It mirrors the jobs in .github/workflows/ one
# for one, so a green run here means what a green run on GitHub means. Used while GitHub Actions
# cannot run for this repository (see docs/architecture.md, "When GitHub Actions cannot run").
#
#   scripts/ci-local.sh            run every job that applies to the change against origin/main
#   scripts/ci-local.sh --all      also run the jobs CI would skip for this change (infra, rendering)
#
# Run it from inside the checkout to be judged: it uses the repository the shell is in, so the
# script can be called from another checkout of this repository. It changes no tracked file.
# Exit 0 = every job passed, 1 = at least one failed. Needs: node, python3, gitleaks,
# osv-scanner, and for infra changes tofu and trivy.
set -uo pipefail
root="$(git rev-parse --show-toplevel)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$root"
all=0; [ "${1:-}" = "--all" ] && all=1
base="$(git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD)"
changed="$(git diff --name-only "$base" HEAD; git status --porcelain | awk '{print $2}')"

failed=()
job() {  # job "<name as on GitHub>" <command...>
  local name="$1"; shift
  local log; log="$(mktemp)"
  printf '%-62s ' "$name"
  if "$@" >"$log" 2>&1; then echo "pass"; else echo "FAIL"; failed+=("$name"); tail -25 "$log" | sed 's/^/    /'; fi
  rm -f "$log"
}
skip() { printf '%-62s %s\n' "$1" "skipped: $2"; }

echo "local CI for $(git rev-parse --abbrev-ref HEAD) at $(git rev-parse --short HEAD), against origin/main"
[ -n "$(git status --porcelain)" ] && echo "note: the working tree has uncommitted changes; they are included in what is judged"

# ci.yml
[ -d site/node_modules ] || npm --prefix site ci >/dev/null 2>&1
job "Site gate (lint, build, links, SEO)" bash scripts/check.sh site
if [ "$all" = 1 ] || bash scripts/visual-changed.sh >/dev/null 2>&1; then
  job "Mobile and desktop rendering (every page, four widths)" bash scripts/check.sh mobile
else
  skip "Mobile and desktop rendering (every page, four widths)" "nothing that affects rendering changed, as in CI"
fi
job "Toolkit gates (docs, claims, plans, hardcoding, public readiness)" bash scripts/check.sh gates
job "Secret scan (gitleaks)" gitleaks detect --source . --redact --no-banner

# security.yml (CodeQL runs only once the repository is public)
job "OSV-Scanner (dependency CVEs)" osv-scanner scan source --lockfile=site/package-lock.json
skip "CodeQL JavaScript / TypeScript" "runs only when the repository is public, as in CI"

# deploy.yml: the build and the gate are the site gate above; the upload needs Cloudflare
# credentials and GitHub, so nothing is published from here.
skip "Build, gate and deploy to Cloudflare Pages" "build and gate covered above; no upload from a local run"

# iac.yml, only when infra/ or its workflow changed
if [ "$all" = 1 ] || grep -qE '^(infra/|\.github/workflows/iac\.yml)' <<<"$changed"; then
  job "tofu fmt + validate" bash -c 'cd infra && tofu fmt -check -diff && tofu init -backend=false -input=false >/dev/null && tofu validate'
  job "Static scan (Trivy misconfiguration and secrets)" trivy fs --scanners misconfig,secret --severity MEDIUM,HIGH,CRITICAL --exit-code 1 infra
else
  skip "tofu fmt + validate; Trivy static scan" "infra/ did not change, as in CI"
fi

echo
if [ "${#failed[@]}" -gt 0 ]; then
  echo "local CI: FAILED (${#failed[@]}): ${failed[*]}"; exit 1
fi
echo "local CI: passed"
