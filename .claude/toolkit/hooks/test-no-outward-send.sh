#!/usr/bin/env bash
# Tests for no-outward-send.sh.
#
# The hook is tested by feeding it synthetic PreToolUse JSON on stdin. NOTHING
# here calls a sending tool, and nothing here may ever be changed to. A test
# that proves the denial works by sending a message has already failed.
#
# Three things are asserted:
#   - every tool the guard is meant to deny is denied, including under a server
#     hash it has never seen, which is the property that keeps it working when
#     the connectors are reconfigured
#   - every tool the repository needs in order to draft, read and search still
#     passes untouched
#   - the guard denies when it cannot understand its own input
#
# Run: .claude/hooks/test-no-outward-send.sh

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/no-outward-send.sh"
pass=0; fail=0; failed_cases=""

# EVERY case below runs with SCT_VIA explicitly cleared unless it is the one
# under test. Without that, the suite's result depended on the environment of
# whoever ran it: an operator with a live governance-publishing grant in their
# shell would have watched the default-deny cases turn green for the wrong
# reason, which is the failure mode this whole file exists to catch.
decision() {
  local out
  out=$(printf '%s' "$1" | env -u SCT_VIA "$HOOK" 2>/dev/null || true)
  if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then
    printf 'deny'
  elif [ -z "$out" ]; then
    printf 'allow'
  else
    printf 'other:%s' "$out"
  fi
}

check() { # check <expected> <label> <payload>
  local got; got=$(decision "$3")
  if [ "$got" = "$1" ]; then
    pass=$((pass + 1)); printf '  ok    %-6s %s\n' "$1" "$2"
  else
    fail=$((fail + 1)); failed_cases="${failed_cases}    $2 (expected $1, got $got)\n"
    printf '  FAIL  %-6s %s   -> got %s\n' "$1" "$2" "$got"
  fi
}

tool()  { jq -nc --arg t "$1" '{tool_name:$t,tool_input:{}}'; }
bash_c() { jq -nc --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}'; }

deny_tool()  { check deny  "tool  $1" "$(tool "$1")"; }
allow_tool() { check allow "tool  $1" "$(tool "$1")"; }
deny_cmd()   { check deny  "bash  $1" "$(bash_c "$1")"; }
allow_cmd()  { check allow "bash  $1" "$(bash_c "$1")"; }

# The declared variants: the same call, with the governance-publishing grant in
# the hook's environment rather than in the payload.
decision_via() { # decision_via <SCT_VIA value> <payload>
  local out
  out=$(printf '%s' "$2" | SCT_VIA="$1" "$HOOK" 2>/dev/null || true)
  if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then printf 'deny'
  elif [ -z "$out" ]; then printf 'allow'
  else printf 'other:%s' "$out"; fi
}
check_via() { # check_via <expected> <SCT_VIA> <label> <payload>
  local got; got=$(decision_via "$2" "$4")
  if [ "$got" = "$1" ]; then
    pass=$((pass + 1)); printf '  ok    %-6s %s\n' "$1" "$3"
  else
    fail=$((fail + 1)); failed_cases="${failed_cases}    $3 (expected $1, got $got)\n"
    printf '  FAIL  %-6s %s   -> got %s\n' "$1" "$3" "$got"
  fi
}

# Two different opaque server ids, neither of which the guard knows about.
A="mcp__1d71e0fa-f559-415e-8d98-4b705052bc49"
B="mcp__13367ee8-67b9-4468-b857-5410a948348b"
C="mcp__fe15bef2-ab05-471d-a54c-710720a76740"
D="mcp__421312b9-47aa-40c7-9203-58a1fcdf88c6"
E="mcp__b8aa4aae-9b60-4689-ae1f-8ca8de3643a3"
X="mcp__00000000-0000-0000-0000-000000000000"   # a hash that has never existed

echo
echo "== denied: Slack outward =="
deny_tool "${A}__slack_send_message"
deny_tool "${X}__slack_send_message"            # hash independence
deny_tool "slack_send_message"                  # and with no server prefix at all
deny_tool "${A}__slack_schedule_message"
deny_tool "${A}__slack_add_reaction"
deny_tool "${A}__slack_create_canvas"
deny_tool "${A}__slack_update_canvas"
deny_tool "${A}__slack_create_conversation"

echo
echo "== denied: mail outward =="
deny_tool "${B}__send_message"
deny_tool "${B}__reply"
deny_tool "${B}__forward"
deny_tool "mcp__ccd_session_mgmt__send_message" # documented over-denial, see the script header

echo
echo "== denied: mail destructive =="
deny_tool "${B}__trash_message"
deny_tool "${B}__trash_thread"
deny_tool "${B}__mark_message_spam"
deny_tool "${B}__mark_thread_spam"

echo
echo "== denied: calendar outward =="
deny_tool "${C}__create_event"
deny_tool "${C}__update_event"
deny_tool "${C}__delete_event"
deny_tool "${C}__respond_to_event"

echo
echo "== denied: other messaging and signature =="
deny_tool "mcp__Read_and_Send_iMessages__send_imessage"
deny_tool "${D}__createEnvelope"
deny_tool "${D}__createEnvelopeFromTemplate"
deny_tool "${D}__sendReminder"
deny_tool "${D}__triggerWorkflow"

echo
echo "== denied: Atlassian MCP writes =="
# The same tracker acli reaches, over a transport the shell layer cannot see.
deny_tool "${E}__createJiraIssue"
deny_tool "${E}__editJiraIssue"
deny_tool "${E}__transitionJiraIssue"
deny_tool "${E}__addCommentToJiraIssue"
deny_tool "${E}__addWorklogToJiraIssue"
deny_tool "${E}__createIssueLink"
deny_tool "${X}__transitionJiraIssue"            # hash independence
deny_tool "addCommentToJiraIssue"                # and with no server prefix at all
deny_tool "${E}__createConfluencePage"
deny_tool "${E}__updateConfluencePage"
deny_tool "${E}__createConfluenceFooterComment"
deny_tool "${E}__createConfluenceInlineComment"
deny_tool "${E}__createCompassComponent"
deny_tool "${E}__createCompassComponentRelationship"
deny_tool "${E}__createCompassCustomFieldDefinition"
deny_tool "${E}__addTeamworkGraphContext"

echo
echo "== allowed: Atlassian MCP reads =="
# Detection is the whole reason the server is wired in. If these stop passing,
# Confluence goes back to being discovered by nothing.
allow_tool "${E}__atlassianUserInfo"
allow_tool "${E}__getAccessibleAtlassianResources"
allow_tool "${E}__searchJiraIssuesUsingJql"
allow_tool "${E}__getJiraIssue"
allow_tool "${E}__getTransitionsForJiraIssue"    # LISTS transitions; does not perform one
allow_tool "${E}__getJiraProjectIssueTypesMetadata"
allow_tool "${E}__getVisibleJiraProjects"
allow_tool "${E}__lookupJiraAccountId"
allow_tool "${E}__searchConfluenceUsingCql"
allow_tool "${E}__getConfluencePage"
allow_tool "${E}__getConfluencePageFooterComments"
allow_tool "${E}__getConfluencePageInlineComments"
allow_tool "${E}__getConfluenceSpaces"
allow_tool "${E}__getPagesInConfluenceSpace"
allow_tool "${E}__getTeamworkGraphContext"

echo
echo "== allowed: drafting =="
allow_tool "${A}__slack_send_message_draft"     # differs from the denied name by a suffix
allow_tool "slack_send_message_draft"
allow_tool "${B}__create_draft"
allow_tool "${B}__update_draft"
allow_tool "${B}__get_draft"
allow_tool "${B}__list_drafts"

echo
echo "== allowed: Slack reads and searches =="
allow_tool "${A}__slack_read_channel"
allow_tool "${A}__slack_read_thread"
allow_tool "${A}__slack_read_canvas"
allow_tool "${A}__slack_read_file"
allow_tool "${A}__slack_read_user_profile"
allow_tool "${A}__slack_search_public"
allow_tool "${A}__slack_search_public_and_private"
allow_tool "${A}__slack_search_channels"
allow_tool "${A}__slack_search_users"
allow_tool "${A}__slack_search_emojis"
allow_tool "${A}__slack_list_channel_members"
allow_tool "${A}__slack_get_reactions"

echo
echo "== allowed: mail and calendar reads =="
allow_tool "${B}__search_threads"
allow_tool "${B}__get_message"
allow_tool "${B}__get_thread"
allow_tool "${B}__list_labels"
allow_tool "${C}__list_events"
allow_tool "${C}__search_events"
allow_tool "${C}__get_event"
allow_tool "${C}__list_calendars"
allow_tool "${C}__suggest_time"

echo
echo "== allowed: Drive reads and ordinary file tools =="
allow_tool "mcp__fcc14987-996c-42aa-80a3-ae8d148d152a__read_file_content"
allow_tool "mcp__fcc14987-996c-42aa-80a3-ae8d148d152a__search_files"
allow_tool "mcp__fcc14987-996c-42aa-80a3-ae8d148d152a__get_file_metadata"
allow_tool "mcp__fcc14987-996c-42aa-80a3-ae8d148d152a__list_recent_files"
allow_tool "mcp__fcc14987-996c-42aa-80a3-ae8d148d152a__download_file_content"
allow_tool "Read"
allow_tool "Edit"
allow_tool "Write"
allow_tool "Glob"
allow_tool "Grep"

echo
echo "== denied: shell routes to the same APIs =="
deny_cmd "curl -X POST https://slack.com/api/chat.postMessage -d channel=C123 -d text=hi"
deny_cmd "curl -X POST https://slack.com/api/chat.scheduleMessage -d channel=C123"
deny_cmd "curl -X POST https://slack.com/api/chat.postEphemeral -d channel=C123"
deny_cmd "curl -d payload=hi https://hooks.slack.com/services/T00/B00/xxxx"
deny_cmd "curl -X POST https://gmail.googleapis.com/gmail/v1/users/me/messages/send"
deny_cmd "wget --post-data=text=hi https://slack.com/api/chat.postMessage"
deny_cmd "curl -X POST https://www.googleapis.com/calendar/v3/calendars/primary/events --data @invite.json"
deny_cmd "ls -la && curl -X POST https://slack.com/api/chat.postMessage -d text=hi"

echo
echo "== denied: Jira writes =="
deny_cmd "acli jira workitem comment --key SEC-1 --body \"done\""
deny_cmd "acli jira workitem transition --key SEC-1 --status Done"
deny_cmd "acli jira workitem assign --key SEC-1 --assignee gio"
deny_cmd "acli jira workitem create --project SEC --summary test"
deny_cmd "acli jira workitem edit --key SEC-1 --summary test"
deny_cmd "acli jira workitem delete --key SEC-1"

echo
echo "== denied: AppleScript and GitHub speech =="
deny_cmd "osascript -e 'tell application \"Messages\" to send \"hi\" to buddy \"x\"'"
deny_cmd "osascript -e 'tell application \"Mail\" to send outgoing message 1'"
deny_cmd "gh pr comment 12 --body \"looks good\""
deny_cmd "gh issue comment 12 --body \"looks good\""
deny_cmd "gh pr review 12 --approve"
deny_cmd "gh api repos/o/r/issues/12/comments -X POST -f body=hi"

echo
echo "== denied: Google Workspace CLI (gws) sends and writes =="
# The `+` helpers.
deny_cmd "gws gmail +send --to someone@example.com --subject hi --body hi"
deny_cmd "gws gmail +reply --id 123 --body hi"
deny_cmd "gws gmail +reply-all --id 123 --body hi"
deny_cmd "gws gmail +forward --id 123 --to someone@example.com"
# The API methods underneath them. A guard that stops the shorthand and passes
# the real method is worse than no guard, because it still looks present.
deny_cmd "gws gmail users messages send --json '{\"raw\":\"...\"}'"
deny_cmd "gws gmail users drafts send --json '{\"id\":\"r123\"}'"
deny_cmd "gws gmail users messages insert --json '{\"raw\":\"...\"}'"
deny_cmd "gws gmail users messages import --json '{\"raw\":\"...\"}'"
# Destructive mailbox verbs, the same class as the connector's trash and spam.
deny_cmd "gws gmail users messages trash --params '{\"id\":\"abc\"}'"
deny_cmd "gws gmail users messages delete --params '{\"id\":\"abc\"}'"
deny_cmd "gws gmail users messages batchDelete --json '{\"ids\":[\"a\"]}'"
deny_cmd "gws gmail users threads delete --params '{\"id\":\"abc\"}'"
# Calendar writes mail every attendee.
deny_cmd "gws calendar events insert --json '{\"summary\":\"sync\"}'"
deny_cmd "gws calendar events update --json '{\"summary\":\"sync\"}'"
deny_cmd "gws calendar events patch --json '{\"summary\":\"sync\"}'"
deny_cmd "gws calendar events delete --params '{\"eventId\":\"e1\"}'"
deny_cmd "gws calendar events quickAdd --params '{\"text\":\"lunch tomorrow\"}'"
# Chat speech and Drive sharing.
deny_cmd "gws chat spaces messages create --json '{\"text\":\"hi\"}'"
deny_cmd "gws drive permissions create --json '{\"role\":\"reader\"}'"
# The env-prefix form, which is exactly how this CLI is meant to be invoked here,
# so it must not become a way past the guard.
deny_cmd "GOOGLE_WORKSPACE_CLI_CONFIG_DIR=/tmp/p gws gmail +send --to someone@example.com"
deny_cmd "GOOGLE_WORKSPACE_CLI_CONFIG_DIR=/tmp/p gws gmail users messages send --json '{}'"

echo
echo "== allowed: gws reads and drafting =="
allow_cmd "gws gmail users messages list --params '{\"userId\":\"me\",\"q\":\"is:unread\"}'"
allow_cmd "gws gmail users messages get --params '{\"userId\":\"me\",\"id\":\"abc\"}'"
allow_cmd "gws gmail users threads list --params '{\"userId\":\"me\"}'"
allow_cmd "gws gmail users getProfile --params '{\"userId\":\"me\"}'"
allow_cmd "gws gmail users labels list --params '{\"userId\":\"me\"}'"
# Drafting is the whole point of the design and must stay open.
allow_cmd "gws gmail users drafts create --json '{\"message\":{\"raw\":\"...\"}}'"
allow_cmd "gws gmail users drafts update --json '{\"message\":{\"raw\":\"...\"}}'"
allow_cmd "gws gmail users drafts list --params '{\"userId\":\"me\"}'"
allow_cmd "gws gmail users drafts get --params '{\"userId\":\"me\",\"id\":\"r1\"}'"
allow_cmd "gws calendar events list --params '{\"calendarId\":\"primary\"}'"
allow_cmd "gws calendar events get --params '{\"eventId\":\"e1\"}'"
allow_cmd "gws drive files list --params '{\"pageSize\":10}'"
allow_cmd "gws drive files get --params '{\"fileId\":\"abc\"}'"
allow_cmd "gws auth status"
allow_cmd "gws schema gmail.users.messages.list"
allow_cmd "GOOGLE_WORKSPACE_CLI_CONFIG_DIR=/tmp/p gws gmail users messages list --params '{}'"

# A bare NAME=value prefix is how a shell accepts per-command environment, and it
# used to defeat every rule in the shell layer: PRE covered `sudo ` and
# `env VAR=val ` but not the bare form, so after `FOO=bar ` there was no command
# position left for POS to match and the call walked straight past.
#
# The SCT_VIA case is the one that matters. The sibling gitops-via-skills guard
# tells operators to write exactly `SCT_VIA=<skill> gh ...`, so following one
# guard's documented instructions silently disabled this one.
deny_cmd "FOO=bar gh pr comment 12 --body \"looks good\""
deny_cmd "SCT_VIA=sc-land-pr gh pr comment 12 --body \"looks good\""
deny_cmd "SCT_VIA=sc-open-pr gh issue comment 12 --body \"looks good\""
deny_cmd "X=1 Y=2 gh pr review 12 --approve"
deny_cmd "RETRIES=3 curl -X POST https://slack.com/api/chat.postMessage"

check deny "tool  osascript connector driving Messages" \
  "$(jq -nc '{tool_name:"mcp__Control_your_Mac__osascript",tool_input:{script:"tell application \"Messages\" to send \"hi\" to buddy \"x\""}}')"

echo
echo "== allowed: ordinary work =="
allow_cmd "curl -s https://slack.com/api/conversations.history?channel=C123"
allow_cmd "curl -s https://gmail.googleapis.com/gmail/v1/users/me/threads"
allow_cmd "curl -s https://api.github.com/repos/o/r"
allow_cmd "wget https://example.com/reference.pdf"
allow_cmd "acli jira workitem search --jql \"project = SEC\""
allow_cmd "acli jira workitem view --key SEC-1"
allow_cmd "gh pr list"
allow_cmd "gh pr view 12"
allow_cmd "gh issue view 12"
allow_cmd "gh api repos/o/r/pulls/12"
allow_cmd "git status --short"
# The prefix fix must not swallow reads that merely carry an assignment.
allow_cmd "SCT_VIA=sc-land-pr gh pr list"
allow_cmd "MSG=review gh pr view 12"
allow_cmd "FOO=bar git status --short"

# REGRESSION, 2026-08-27. The gh api rule tested its three conditions against the
# WHOLE command string, so an ordinary commit was denied whenever its message
# mentioned a review or a comment and an unrelated gh api read sat beside it.
# Neither suite had a `git commit` case at all, so the pre-fix guard scored a
# clean 105/105 while the bug was live in every session on the machine. These
# three cases are the ones that were failing in practice.
allow_cmd "git commit -m 'fix: address the review feedback'"
allow_cmd "git commit -m 'chore: tidy the comment blocks'"
# This is the exact shape that failed: a harmless read supplies `gh api`, the
# commit supplies the field flag, and the filename supplies the word. All three
# hold across the command and none of them holds within the gh api segment.
allow_cmd "gh api user; git commit -F review-notes.txt"

allow_cmd "rg -n 'postMessage' docs/"
allow_cmd "echo 'the note explains curl and chat.postMessage as background'"
allow_cmd "osascript -e 'tell application \"Finder\" to activate'"
allow_cmd "osascript -e 'tell application \"Mail\" to get unread count of inbox'"
allow_tool "Bash"

echo
echo "== governance publishing: the declared route =="
# The one way past the Confluence page deny. These are the cases that decide
# whether it is a route or a hole.

# Undeclared, the default, asserted above too: a page is still denied.
deny_tool "${E}__createConfluencePage"

# Declared. This is the behaviour the route exists to provide.
check_via allow "sc-publish-gov-doc" "declared createConfluencePage" "$(tool "${E}__createConfluencePage")"
check_via allow "sc-publish-gov-doc" "declared updateConfluencePage" "$(tool "${E}__updateConfluencePage")"
check_via allow "sc-publish-gov-doc" "declared, unknown server hash"  "$(tool "${X}__createConfluencePage")"

# The declaration must LOOK like one. Substring, prefix and empty values are
# not declarations -- gitops-via-skills.sh learned this the hard way.
check_via deny ""                          "empty SCT_VIA"           "$(tool "${E}__createConfluencePage")"
check_via deny "sc-publish-gov-doc-lol"               "SCT_VIA with a suffix"   "$(tool "${E}__createConfluencePage")"
check_via deny "not-sc-publish-gov-doc"               "SCT_VIA with a prefix"   "$(tool "${E}__createConfluencePage")"
check_via deny "sc-open-pr"                "a different skill"       "$(tool "${E}__createConfluencePage")"
check_via deny "lol"                       "any value at all"        "$(tool "${E}__createConfluencePage")"

# THE BLAST RADIUS. The grant authorises a document and nothing else. If any of
# these ever turn green, the declaration has stopped being a page route and
# become a general Atlassian write key.
check_via deny "sc-publish-gov-doc" "declared: footer comment stays denied" "$(tool "${E}__createConfluenceFooterComment")"
check_via deny "sc-publish-gov-doc" "declared: inline comment stays denied" "$(tool "${E}__createConfluenceInlineComment")"
check_via deny "sc-publish-gov-doc" "declared: Jira comment stays denied"   "$(tool "${E}__addCommentToJiraIssue")"
check_via deny "sc-publish-gov-doc" "declared: Jira transition stays denied" "$(tool "${E}__transitionJiraIssue")"
check_via deny "sc-publish-gov-doc" "declared: Compass write stays denied"  "$(tool "${E}__createCompassComponent")"
check_via deny "sc-publish-gov-doc" "declared: Slack send stays denied"     "$(tool "${A}__slack_send_message")"
check_via deny "sc-publish-gov-doc" "declared: mail send stays denied"      "$(tool "${B}__send_message")"

echo
echo "== governance publishing: the same acts through curl =="
# The tool-name deny above was a door with a wall beside it until these existed.
deny_cmd  'curl -X POST https://acme.atlassian.net/wiki/api/v2/pages -d @page.json'
deny_cmd  'curl -X PUT https://acme.atlassian.net/wiki/api/v2/pages/123 --data @p.json'
deny_cmd  'curl -X POST https://acme.atlassian.net/wiki/rest/api/content -d @p.json'
deny_cmd  'curl -X POST https://acme.atlassian.net/rest/api/3/issue -d @issue.json'
deny_cmd  'wget --post-data=@p.json https://acme.atlassian.net/wiki/api/v2/pages'
# The env-prefix regression: a declaration for a DIFFERENT guard must not open
# this one. This is the SCT_VIA=sc-open-pr lesson, transposed.
deny_cmd  'SCT_VIA=sc-open-pr curl -X POST https://acme.atlassian.net/wiki/api/v2/pages -d @p.json'
deny_cmd  'SCT_VIA=sc-publish-gov-doc-lol curl -X POST https://acme.atlassian.net/wiki/api/v2/pages -d @p.json'

# Declared on the command line, where a prefix genuinely is a command line.
allow_cmd 'SCT_VIA=sc-publish-gov-doc curl -X POST https://acme.atlassian.net/wiki/api/v2/pages -d @page.json'
allow_cmd 'SCT_VIA=sc-publish-gov-doc curl -X PUT https://acme.atlassian.net/wiki/api/v2/pages/123 -d @page.json'
# ...and it still does not reach Jira, a space or a permission grant.
deny_cmd  'SCT_VIA=sc-publish-gov-doc curl -X POST https://acme.atlassian.net/rest/api/3/issue -d @issue.json'
deny_cmd  'SCT_VIA=sc-publish-gov-doc curl -X POST https://acme.atlassian.net/wiki/rest/api/space -d @s.json'

# Reading Atlassian is work, and stays work.
allow_cmd 'curl -s https://acme.atlassian.net/wiki/api/v2/pages/123'
allow_cmd 'curl https://acme.atlassian.net/rest/api/3/search?jql=project=TK'
allow_cmd 'acli jira workitem view TK-051'

echo
echo "== fail closed =="
check deny "empty stdin"                ""
check deny "unparseable JSON"           '{"tool_name": '
check deny "JSON that is not an object" '[1,2,3]'
check deny "no tool_name"               '{"tool_input":{"command":"ls"}}'
check deny "empty tool_name"            '{"tool_name":"","tool_input":{}}'

# jq removed from PATH. The guard must deny rather than wave everything through.
out=$(printf '%s' "$(tool "Read")" | PATH=/nonexistent /bin/bash "$HOOK" 2>/dev/null || true)
if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then
  pass=$((pass + 1)); printf '  ok    %-6s %s\n' "deny" "no jq on PATH"
else
  fail=$((fail + 1)); failed_cases="${failed_cases}    no jq on PATH (expected deny, got '${out}')\n"
  printf '  FAIL  %-6s %s   -> got %s\n' "deny" "no jq on PATH" "${out:-allow}"
fi

echo
echo "----------------------------------------"
printf '%d passed, %d failed\n' "$pass" "$fail"
if [ "$fail" -gt 0 ]; then
  printf 'failing cases:\n'; printf "$failed_cases"
  exit 1
fi
echo "no-outward-send guard: all cases pass."
