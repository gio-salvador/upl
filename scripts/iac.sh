#!/usr/bin/env bash
# Runs OpenTofu for infra/ with the narrow credentials in the git-ignored .env that
# scripts/bootstrap-cloudflare.sh writes, and hands the same values to GitHub. It maps .env to
# exactly the variables .github/workflows/iac.yml passes, so a local run and a CI run agree.
#
# Usage:
#   bash scripts/iac.sh init       connect to the state bucket
#   bash scripts/iac.sh plan       show what would change
#   bash scripts/iac.sh apply      make it so (asks before changing anything)
#   bash scripts/iac.sh output     print the outputs (the DS record, the domain status, ...)
#   bash scripts/iac.sh github     set the repository secrets and variables, turn the IaC workflow on
#   bash scripts/iac.sh status     check the credentials, the state, GitHub and the live address
#   bash scripts/iac.sh tofu ...   any other tofu command, with the environment set
#
# The custom domain follows docs/runbook-go-live.md, step 8: set SITE_DOMAIN in .env, apply,
# wait for `status` to show both domains active, then set SITE, run `github`, and redeploy.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ENV_FILE=.env
die() { printf 'iac: %s\n' "$*" >&2; exit 1; }
case "${1:-}" in ""|-h|--help) sed -n '2,16p' "$0"; exit 0 ;; esac
[ -f "$ENV_FILE" ] || die "no $ENV_FILE; run scripts/bootstrap-cloudflare.sh first"
git check-ignore -q "$ENV_FILE" || die "$ENV_FILE is not git-ignored"
set -a
# shellcheck disable=SC1090
. "./$ENV_FILE"
set +a
for k in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID TOFU_STATE_BUCKET TOFU_STATE_ACCESS_KEY_ID TOFU_STATE_SECRET_ACCESS_KEY TOFU_STATE_ENDPOINT; do
  [ -n "${!k:-}" ] || die "$k is empty in $ENV_FILE; run scripts/bootstrap-cloudflare.sh"
done

export AWS_ACCESS_KEY_ID="$TOFU_STATE_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$TOFU_STATE_SECRET_ACCESS_KEY"
export TF_VAR_cloudflare_api_token="$CLOUDFLARE_API_TOKEN" TF_VAR_cloudflare_account_id="$CLOUDFLARE_ACCOUNT_ID"
export TF_VAR_pages_project_name="${PAGES_PROJECT_NAME:-}" TF_VAR_site_origin="${SITE:-}" TF_VAR_site_domain="${SITE_DOMAIN:-}"
export TF_IN_AUTOMATION=1

init() {
  tofu -chdir=infra init -input=false -reconfigure \
    -backend-config="bucket=$TOFU_STATE_BUCKET" \
    -backend-config="endpoints={s3=\"$TOFU_STATE_ENDPOINT\"}" "$@"
}
ensure_init() { [ -d infra/.terraform ] && [ -f infra/.terraform/terraform.tfstate ] || init >/dev/null; }

cmd="${1:-}"; [ $# -eq 0 ] || shift
case "$cmd" in
  init) init "$@" ;;
  plan) ensure_init; tofu -chdir=infra plan -input=false "$@" ;;
  apply) ensure_init; tofu -chdir=infra apply -input=false "$@" ;;
  output) ensure_init; tofu -chdir=infra output "$@" ;;
  tofu) ensure_init; tofu -chdir=infra "$@" ;;

  github)
    command -v gh >/dev/null 2>&1 || die "missing gh"
    repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)" || die "gh cannot see this repository; check gh auth status"
    echo "Setting secrets and variables on $repo"
    # Values go in on stdin, so they never appear on a command line or in shell history.
    for k in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID TOFU_STATE_BUCKET TOFU_STATE_ACCESS_KEY_ID TOFU_STATE_SECRET_ACCESS_KEY TOFU_STATE_ENDPOINT; do
      printf '%s' "${!k}" | gh secret set "$k" >/dev/null && echo "  secret   $k"
    done
    ensure_init
    project="$(tofu -chdir=infra output -raw pages_project_name 2>/dev/null)" ||
      die "no pages_project_name output yet; run 'bash scripts/iac.sh apply' first, so CI never deploys to a project that does not exist"
    site="${SITE:-$(tofu -chdir=infra output -raw site_origin)}"
    gh variable set PAGES_PROJECT_NAME --body "$project" >/dev/null && echo "  variable PAGES_PROJECT_NAME=$project"
    gh variable set SITE --body "$site" >/dev/null && echo "  variable SITE=$site"
    if [ -n "${SITE_DOMAIN:-}" ]; then
      gh variable set SITE_DOMAIN --body "$SITE_DOMAIN" >/dev/null && echo "  variable SITE_DOMAIN=$SITE_DOMAIN"
    elif gh variable get SITE_DOMAIN >/dev/null 2>&1; then
      gh variable delete SITE_DOMAIN >/dev/null && echo "  variable SITE_DOMAIN removed (empty in $ENV_FILE)"
    fi
    gh variable set IAC_ENABLED --body true >/dev/null && echo "  variable IAC_ENABLED=true"
    echo "Done. Run the Deploy workflow: gh workflow run deploy.yml --ref main"
    ;;

  status)
    rc=0
    line() { printf '  %-34s %s\n' "$1" "$2"; }
    bad() { line "$1" "$2"; rc=1; }
    verify() { printf 'header = "Authorization: Bearer %s"\n' "$CLOUDFLARE_API_TOKEN" | curl -sS -m 20 -K - "https://api.cloudflare.com/client/v4$1" | jq -e '.success == true' >/dev/null 2>&1; }
    if verify /user/tokens/verify || verify "/accounts/$CLOUDFLARE_ACCOUNT_ID/tokens/verify"; then line "deploy token" "active"; else bad "deploy token" "NOT VALID"; fi
    if verify "/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects"; then line "deploy token, Pages" "allowed"; else bad "deploy token, Pages" "REFUSED"; fi
    if init >/dev/null 2>&1; then line "state bucket" "reachable"; else bad "state bucket" "NOT REACHABLE"; fi
    if out="$(tofu -chdir=infra plan -input=false -lock=false -detailed-exitcode -no-color 2>&1)"; then
      line "plan" "no changes: the code and Cloudflare agree"
    elif [ $? -eq 2 ]; then
      bad "plan" "changes pending: $(printf '%s' "$out" | grep -E '^Plan:' || echo 'see bash scripts/iac.sh plan')"
    else
      bad "plan" "FAILED; see bash scripts/iac.sh plan"
    fi
    tofu -chdir=infra output -json custom_domain_status 2>/dev/null | jq -r 'to_entries[]? | "  domain \(.key): \(.value)"' || true
    if command -v gh >/dev/null 2>&1; then
      have="$(gh secret list --json name -q '.[].name' 2>/dev/null | tr '\n' ' ')"
      for k in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID TOFU_STATE_BUCKET TOFU_STATE_ACCESS_KEY_ID TOFU_STATE_SECRET_ACCESS_KEY TOFU_STATE_ENDPOINT; do
        case " $have " in *" $k "*) ;; *) bad "GitHub secret $k" "MISSING" ;; esac
      done
      for k in PAGES_PROJECT_NAME SITE IAC_ENABLED; do
        if v="$(gh variable get "$k" 2>/dev/null)"; then line "GitHub variable $k" "$v"; else bad "GitHub variable $k" "MISSING"; fi
      done
    fi
    origin="${SITE:-$(tofu -chdir=infra output -raw site_origin 2>/dev/null || true)}"
    if [ -n "$origin" ]; then
      code="$(curl -s -o /dev/null -m 15 -w '%{http_code}' "$origin/" || true)"
      if [ "$code" = 200 ]; then line "live site" "$origin answers 200"; else bad "live site" "$origin answers $code (expected until the first deploy)"; fi
    fi
    exit "$rc"
    ;;

  *) die "unknown command '$cmd'; see --help" ;;
esac
