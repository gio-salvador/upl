#!/usr/bin/env bash
# Builds everything on the Cloudflare side that the site needs, from one root token:
#
#   1. the R2 bucket that holds the OpenTofu state
#   2. a narrow deploy token: Cloudflare Pages edit on the one account and, when the domain's
#      zone is in that account, zone read and DNS edit on that one zone
#   3. a narrow R2 token: object read and write on the state bucket only
#   4. a git-ignored .env at the repository root holding the narrow credentials
#
# The root token is used for this run only. It is never written to a file, never passed on a
# command line and never printed. Everything after this script (scripts/iac.sh, CI) uses the
# narrow credentials, so the root token can be revoked as soon as the run is green.
#
# The root token needs: User, API Tokens, Edit (or Account, API Tokens, Edit for an
# account-owned token); Account, Workers R2 Storage, Edit; Account, Account Settings, Read;
# and Zone, Zone, Read. It must not be IP-locked to somewhere else.
#
# Usage:
#   bash scripts/bootstrap-cloudflare.sh [--account ID] [--domain NAME] [--bucket NAME]
#                                        [--project NAME] [--rotate] [--dry-run]
#
#   --account   the Cloudflare account id; only needed when the root token sees several
#   --domain    the apex domain whose zone the deploy token may edit; empty for Pages only
#   --bucket    the state bucket name (default upl-tofu-state)
#   --project   the Pages project name (default unified-path-of-light)
#   --rotate    roll both narrow tokens even when the ones in .env still work
#   --dry-run   look everything up and say what would change; create nothing
#
# The root token is read from CLOUDFLARE_ROOT_TOKEN, or asked for without echo.
# Safe to run again: it converges. Existing tokens have their policies corrected in place and
# are rolled only when .env no longer holds a working value (or with --rotate).
#
# Adapted from salvador-cloud-site (MIT), see THIRD-PARTY-NOTICES.md.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
umask 077

CF=https://api.cloudflare.com/client/v4
ENV_FILE=.env
deploy_name=upl-deploy
state_name=upl-tofu-state
# The only keys this script and scripts/iac.sh own. An .env holding anything else is someone
# else's file, and is never overwritten.
owned="CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID TOFU_STATE_BUCKET TOFU_STATE_ACCESS_KEY_ID TOFU_STATE_SECRET_ACCESS_KEY TOFU_STATE_ENDPOINT PAGES_PROJECT_NAME SITE SITE_DOMAIN"

account="" domain="unifiedpathoflight.com" bucket="upl-tofu-state" project="unified-path-of-light"
rotate=0 dry=0
while [ $# -gt 0 ]; do
  case "$1" in
    --account) account="${2:-}"; shift 2 ;;
    --domain) domain="${2:-}"; shift 2 ;;
    --bucket) bucket="${2:-}"; shift 2 ;;
    --project) project="${2:-}"; shift 2 ;;
    --rotate) rotate=1; shift ;;
    --dry-run) dry=1; shift ;;
    -h|--help) sed -n '2,33p' "$0"; exit 0 ;;
    *) echo "bootstrap: unknown argument '$1'" >&2; exit 2 ;;
  esac
done

step() { printf '\n==> %s\n' "$*"; }
ok() { printf '    ok: %s\n' "$*"; }
note() { printf '    note: %s\n' "$*" >&2; }
die() { printf '    error: %s\n' "$*" >&2; exit 1; }

for bin in curl jq git; do command -v "$bin" >/dev/null 2>&1 || die "missing $bin"; done
sha256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1; }

# --- the existing .env, if any ------------------------------------------------------------
env_get() { [ -f "$ENV_FILE" ] && sed -n "s/^$1=//p" "$ENV_FILE" | head -n 1 || true; }
if [ -f "$ENV_FILE" ]; then
  foreign="$(sed -n 's/^\(export \)\{0,1\}\([A-Za-z_][A-Za-z0-9_]*\)=.*/\2/p' "$ENV_FILE" | while read -r k; do
    case " $owned " in *" $k "*) ;; *) printf '%s ' "$k" ;; esac
  done)"
  [ -z "$foreign" ] || die "$ENV_FILE holds keys this repository does not own ($foreign). It looks like another project's file. Move it out of the repository, then run this again."
fi

# --- the root token -----------------------------------------------------------------------
root="${CLOUDFLARE_ROOT_TOKEN:-}"
if [ -z "$root" ]; then
  [ -t 0 ] || die "set CLOUDFLARE_ROOT_TOKEN, or run this in a terminal to be asked for it"
  printf 'Cloudflare root token (not shown): ' >&2
  IFS= read -r -s root; printf '\n' >&2
fi
[ -n "$root" ] || die "no root token given"

# The token travels in a curl config on stdin, so it never appears in a process listing.
api() { # api METHOD PATH [JSON]
  local method="$1" path="$2" data="${3:-}"
  if [ -n "$data" ]; then
    printf 'header = "Authorization: Bearer %s"\n' "$root" |
      curl -sS -m 30 -K - -X "$method" -H 'Content-Type: application/json' --data "$data" "$CF$path"
  else
    printf 'header = "Authorization: Bearer %s"\n' "$root" | curl -sS -m 30 -K - -X "$method" "$CF$path"
  fi
}
succeeded() { jq -e '.success == true' >/dev/null 2>&1; }
errors() { jq -c '[.errors[]? | {code, message}]' 2>/dev/null || cat; }

step "1. Root token and account"
if [ -z "$account" ]; then account="$(env_get CLOUDFLARE_ACCOUNT_ID)"; fi
if [ -z "$account" ]; then
  accounts="$(api GET '/accounts?per_page=50')"
  printf '%s' "$accounts" | succeeded || die "cannot list accounts: $(printf '%s' "$accounts" | errors)"
  count="$(printf '%s' "$accounts" | jq '.result | length')"
  if [ "$count" = 1 ]; then
    account="$(printf '%s' "$accounts" | jq -r '.result[0].id')"
  else
    printf '%s' "$accounts" | jq -r '.result[] | "      \(.id)  \(.name)"' >&2
    die "the root token sees $count accounts; pass --account with the one that should own the site"
  fi
fi
account_name="$(api GET "/accounts/$account" | jq -r '.result.name // empty')"
[ -n "$account_name" ] || die "the root token cannot read that account (needs Account Settings, Read)"
ok "account: $account_name"

# A user-owned root token manages tokens under /user; an account-owned one under the account.
if api GET '/user/tokens/permission_groups' | succeeded; then
  tokens="/user/tokens"
elif api GET "/accounts/$account/tokens/permission_groups" | succeeded; then
  tokens="/accounts/$account/tokens"
else
  die "the root token cannot manage API tokens (needs User or Account, API Tokens, Edit)"
fi
ok "token API: $tokens"
groups="$(api GET "$tokens/permission_groups")"
group_id() { # group_id SCOPE NAME [NAME...]  first name that exists wins (Cloudflare renames these)
  local scope="$1" id; shift
  for name in "$@"; do
    id="$(printf '%s' "$groups" | jq -r --arg n "$name" --arg s "$scope" \
      '[.result[] | select(.name == $n) | select(.scopes | index($s))][0].id // empty')"
    [ -z "$id" ] || { printf '%s' "$id"; return 0; }
  done
  die "no permission group named any of: $*"
}

step "2. Zone for the custom domain"
zone_id=""
if [ -n "$domain" ]; then
  zone_id="$(api GET "/zones?name=$domain&account.id=$account" | jq -r '.result[0].id // empty')"
  if [ -n "$zone_id" ]; then
    ok "$domain is in this account; the deploy token will also get zone read and DNS edit on it"
  else
    note "$domain is not a zone in this account (or the root token lacks Zone, Read)."
    note "The deploy token will cover Pages only. Run this again once the zone is there."
  fi
else
  ok "no domain given; the deploy token will cover Pages only"
fi

step "3. State bucket"
if api GET "/accounts/$account/r2/buckets/$bucket" | succeeded; then
  ok "bucket $bucket exists"
elif [ "$dry" = 1 ]; then
  ok "would create bucket $bucket"
else
  made="$(api POST "/accounts/$account/r2/buckets" "$(jq -nc --arg n "$bucket" '{name: $n, locationHint: "weur"}')")"
  printf '%s' "$made" | succeeded || die "cannot create the bucket: $(printf '%s' "$made" | errors). If R2 has never been used on this account, turn it on once in the dashboard under R2 (the free allowance is enough), then run this again."
  ok "created bucket $bucket"
fi
endpoint="https://$account.r2.cloudflarestorage.com"

# --- tokens -------------------------------------------------------------------------------
existing="$(api GET "$tokens?per_page=50")"
token_id_by_name() { printf '%s' "$existing" | jq -r --arg n "$1" '[.result[] | select(.name == $n)][0].id // empty'; }

# Prints the token value when a new value was issued, nothing when the old one still stands.
converge_token() { # converge_token NAME POLICIES_JSON KEEP(0|1)
  local name="$1" policies="$2" keep="$3" id body reply
  id="$(token_id_by_name "$name")"
  body="$(jq -nc --arg n "$name" --argjson p "$policies" '{name: $n, status: "active", policies: $p}')"
  if [ -z "$id" ]; then
    if [ "$dry" = 1 ]; then note "would create token $name"; return 0; fi
    reply="$(api POST "$tokens" "$body")"
    printf '%s' "$reply" | succeeded || die "cannot create token $name: $(printf '%s' "$reply" | errors)"
    note "created token $name"
    printf '%s %s' "$(printf '%s' "$reply" | jq -r '.result.id')" "$(printf '%s' "$reply" | jq -r '.result.value')"
    return 0
  fi
  if [ "$dry" = 1 ]; then note "would correct the policies of token $name$([ "$keep" = 1 ] || printf ' and roll its value')"; return 0; fi
  reply="$(api PUT "$tokens/$id" "$body")"
  printf '%s' "$reply" | succeeded || die "cannot update token $name: $(printf '%s' "$reply" | errors)"
  if [ "$keep" = 1 ]; then note "token $name: policies corrected, value kept"; return 0; fi
  reply="$(api PUT "$tokens/$id/value" '{}')"
  printf '%s' "$reply" | succeeded || die "cannot roll token $name: $(printf '%s' "$reply" | errors)"
  note "token $name: policies corrected, value rolled"
  printf '%s %s' "$id" "$(printf '%s' "$reply" | jq -r '.result')"
}

step "4. Deploy token ($deploy_name)"
pages="$(group_id com.cloudflare.api.account 'Pages Write' 'Cloudflare Pages Edit')"
deploy_policies="$(jq -nc --arg a "com.cloudflare.api.account.$account" --arg g "$pages" \
  '[{effect: "allow", resources: {($a): "*"}, permission_groups: [{id: $g}]}]')"
if [ -n "$zone_id" ]; then
  zone_read="$(group_id com.cloudflare.api.account.zone 'Zone Read')"
  dns_edit="$(group_id com.cloudflare.api.account.zone 'DNS Write' 'DNS Edit')"
  deploy_policies="$(printf '%s' "$deploy_policies" | jq -c --arg z "com.cloudflare.api.account.zone.$zone_id" \
    --arg r "$zone_read" --arg d "$dns_edit" \
    '. + [{effect: "allow", resources: {($z): "*"}, permission_groups: [{id: $r}, {id: $d}]}]')"
fi
deploy_value="$(env_get CLOUDFLARE_API_TOKEN)"
keep=0
if [ "$rotate" = 0 ] && [ -n "$deploy_value" ]; then
  if printf 'header = "Authorization: Bearer %s"\n' "$deploy_value" | curl -sS -m 30 -K - "$CF$tokens/verify" | succeeded; then keep=1; fi
fi
issued="$(converge_token "$deploy_name" "$deploy_policies" "$keep")"
[ -z "$issued" ] || deploy_value="${issued#* }"
ok "Pages edit on one account$([ -z "$zone_id" ] || printf ', zone read and DNS edit on one zone')"

step "5. State token ($state_name)"
r2_write="$(group_id com.cloudflare.edge.r2.bucket 'Workers R2 Storage Bucket Item Write')"
state_policies="$(jq -nc --arg b "com.cloudflare.edge.r2.bucket.${account}_default_${bucket}" --arg g "$r2_write" \
  '[{effect: "allow", resources: {($b): "*"}, permission_groups: [{id: $g}]}]')"
state_key="$(env_get TOFU_STATE_ACCESS_KEY_ID)"
state_secret="$(env_get TOFU_STATE_SECRET_ACCESS_KEY)"
keep=0
if [ "$rotate" = 0 ] && [ -n "$state_secret" ] && [ "$state_key" = "$(token_id_by_name "$state_name")" ]; then keep=1; fi
issued="$(converge_token "$state_name" "$state_policies" "$keep")"
if [ -n "$issued" ]; then
  # R2's S3 credentials are derived from the API token: the key id is the token id and the
  # secret is the SHA-256 of the token value.
  state_key="${issued%% *}"
  state_secret="$(printf '%s' "${issued#* }" | sha256)"
fi
ok "object read and write on bucket $bucket only"

if [ "$dry" = 1 ]; then
  step "Dry run: nothing was created and $ENV_FILE was not written"
  exit 0
fi

step "6. Writing $ENV_FILE"
site="$(env_get SITE)"; site_domain="$(env_get SITE_DOMAIN)"
tmp="$(mktemp "$ENV_FILE.XXXXXX")"
{
  echo "# Written by scripts/bootstrap-cloudflare.sh. Git-ignored. Narrow credentials only:"
  echo "# the root token is never stored. Read by scripts/iac.sh."
  echo "CLOUDFLARE_API_TOKEN=$deploy_value"
  echo "CLOUDFLARE_ACCOUNT_ID=$account"
  echo "TOFU_STATE_BUCKET=$bucket"
  echo "TOFU_STATE_ACCESS_KEY_ID=$state_key"
  echo "TOFU_STATE_SECRET_ACCESS_KEY=$state_secret"
  echo "TOFU_STATE_ENDPOINT=$endpoint"
  echo "PAGES_PROJECT_NAME=$project"
  echo "# SITE: empty means the pages.dev address. Set it to the custom domain's origin only"
  echo "# after the certificate is active (docs/runbook-go-live.md, step 8)."
  echo "SITE=$site"
  echo "# SITE_DOMAIN: empty means no custom domain and no DNS records."
  echo "SITE_DOMAIN=$site_domain"
} > "$tmp"
chmod 600 "$tmp"; mv "$tmp" "$ENV_FILE"
git check-ignore -q "$ENV_FILE" || die "$ENV_FILE is not git-ignored; refusing to leave credentials where git can see them"
ok "$ENV_FILE written, mode 600, git-ignored"

cat <<EOF

Done. Next:
  bash scripts/iac.sh apply      create the Pages project (expect one resource to add)
  bash scripts/iac.sh github     give GitHub the secrets and variables, and turn the IaC workflow on
  bash scripts/iac.sh status     check that everything agrees

Then revoke the root token in the Cloudflare dashboard. Nothing needs it again; a later
rotation needs a fresh one.
EOF
