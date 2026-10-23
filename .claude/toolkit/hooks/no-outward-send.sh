#!/usr/bin/env bash
# PreToolUse guard: this repository drafts. It does not send.
#
# The mechanical half of .claude/rules/no-outward-send.md, which is itself the
# enforcement of CLAUDE.md 6 "Nothing is sent without approval". The prose says
# an agent must not send. This says an agent cannot.
#
# Two layers, because there are two ways out:
#
#   1. TOOL NAME  - a connector tool whose job is to put words in front of
#      another person: a Slack message, a mail send or reply, a calendar invite,
#      an iMessage, a signature request. Denied outright.
#   2. SHELL      - the same APIs reached through Bash, which the tool-name
#      layer cannot see because to it every one of them is just "Bash".
#      Denied by command pattern.
#
# The two layers have to be kept in step, and the Atlassian case is the standing
# example of why. `acli jira workitem comment` is denied in the shell layer, and
# the Atlassian MCP server reaches the same tracker with the same authority over
# a transport the shell layer cannot see. Denying one and not the other leaves
# the rule intact and the control half-present. Whenever a system gains a second
# route, both layers get the rule or neither does.
#
# WHY THE SUFFIX, NOT THE FULL NAME. MCP tools arrive as
# mcp__<server-id>__<tool>, and the server id here is an opaque hash, for
# example mcp__1d71e0fa-f559-415e-8d98-4b705052bc49__slack_send_message. Those
# hashes are not stable. They differ between machines, and they change when a
# connector is reconfigured. A guard keyed to today's hash would keep passing
# its own tests and would silently stop guarding anything the day the hash
# moved, which is the worst failure a control can have: still present, no
# longer working. So this matches on the text after the final "__" and ignores
# the server entirely.
#
# THE COLLISION, AND THE CHOICE MADE ABOUT IT. Matching on the suffix means
# "send_message", "reply", "forward", "create_event" and friends are denied
# whichever server offers them. Those are generic names and another server can
# legitimately use one. The known case is the session-management connector's
# own send_message, which talks to another agent session rather than to a
# person; it is denied here too. That is deliberate. Over-denying costs a
# session one route to a peer agent, and the Agent tool's SendMessage is still
# available for that. Under-denying costs a client a message they never
# approved. The two are not comparable, so the guard denies the whole suffix
# and this paragraph is the record of the decision.
#
# Matching is on EXACT suffix equality, never prefix or substring, because
# slack_send_message_draft must keep working and differs from slack_send_message
# by a suffix. Drafting is the entire point of the repository.
#
# WHERE THE SHELL BOUNDARY WAS DRAWN. Reading is work; sending is not. So:
#   allowed  - curl or wget doing a GET against any API, including Slack, Gmail
#              and Calendar; acli jira workitem search and view; gh pr list,
#              gh pr view, gh issue view, gh api reads.
#   denied   - an HTTP client naming a send-only endpoint (chat.postMessage and
#              its relatives, a Slack incoming webhook, a Gmail messages/send or
#              drafts/send, a Graph sendMail) at all; an HTTP client using a
#              mutating method or a request body against Slack, Gmail, Calendar,
#              Graph or DocuSign; acli jira workitem comment, transition,
#              assign, create, edit or delete, because a Jira write is a
#              person's act and .claude/rules/jira-write-safety.md in the client
#              repository governs it; osascript driving Mail or Messages to send;
#              gh pr comment, gh issue comment, gh pr review, and a gh api call
#              that POSTs to a comment or review path, because speech in someone
#              else's repository is outward speech; and the `gws` Google Workspace
#              CLI's send surface, which is neither an MCP tool nor an HTTP client
#              and so was reached by no other layer here -- both its `+send`,
#              `+reply`, `+reply-all` and `+forward` helpers AND the API methods
#              they wrap, plus calendar writes, Chat posts and Drive permission
#              grants. `gws` reads and `gws gmail users drafts create/update`
#              stay open, because drafting is the point.
#              and an HTTP write to Atlassian, which until 2026-09-09 was
#              reached by NO layer at all: the tool-name layer denied
#              createConfluencePage while `curl -X POST .../wiki/api/v2/pages`
#              walked straight past it to the same API with the same authority.
#              Atlassian reads over HTTP stay open, as every read here does.
#
# THE DECLARED ROUTES. Everything above is denied outright, with two exceptions,
# each denied by default and allowed only when the caller declares itself.
#
#   1. A Confluence PAGE, for the governance-publishing skill. The reasoning, the
#      shape of the declaration, and an honest account of how strong it is and is
#      not are recorded at GOV_DOC_SKILLS below. It covers a page and stops there
#      -- not a comment, not Jira, not a space, not a permission.
#   2. For incident coordination, recorded at OPERATOR_SKILLS below: a PRIVATE
#      SLACK CHANNEL, a MESSAGE TO A CHANNEL, and a JIRA WRITE INSIDE ONE
#      PROJECT whose key the operator names at launch. It stops there -- not a
#      message to a person, not a public channel, not a scheduled message, not
#      an edit to an existing comment, not a write to any other project, and
#      nothing through the shell.
#
# THE CONNECTOR RENAMES ITS TOOLS, AND THIS GUARD DOES NOT HEAR ABOUT IT. The case
# table below matches the names the Atlassian connector had when it was written. It
# has since renamed several write tools, and a renamed tool is a name this guard has
# never heard of, which it ALLOWS: a hole that is silent, open to every session
# declared or not, and invisible to a test suite that only asserts the old names. Found
# on 2026-10-23 by feeding the hook synthetic payloads for the connector's live tool
# list. So every renamed tool is denied in the same branch as its old spelling and both
# spellings are kept, because the connector may present either. The Confluence pair
# (createConfluenceContent, updateConfluenceContent) honours the governance-publishing
# declaration exactly as createConfluencePage does, although those two tools reach more
# than a document; the reasoning is at their branch below. The standing remedy is outside this file: a consuming
# repository mirrors these names into its permissions.deny second layer, and the next
# connector rename is found by diffing the connector's tool list against this table.
#
# Read both before widening either. The two declarations do not cross: neither
# opens what the other opens. The tests assert every boundary of both by name,
# because the way a narrow exception fails is by quietly becoming a general one.
# Commands are matched as actual invocations, anchored at a command position,
# so a heredoc or a comment that merely mentions curl is not a send.
#
# Hook input  (stdin, JSON): { "tool_name": "...", "tool_input": { ... } }
# Hook output (stdout, JSON): a PreToolUse permissionDecision, or nothing.
# Exit 0 with no output = passthrough, normal permission flow untouched.
#
# FAIL CLOSED. Empty stdin, unparseable JSON, a missing tool name, a missing jq
# or any error at all denies. A guard that opens when it breaks is not a guard.
# Output is built with printf rather than jq so that the denial still reaches
# Claude Code when jq is the thing that is missing; every reason string below is
# therefore plain ASCII with no double quote, backslash or newline in it.
#
# Removing this hook, or the permissions.deny block in .claude/settings.json
# that backs it, is not a casual act. Read .claude/rules/no-outward-send.md
# first. If a message genuinely has to go, a person sends it.

set -euo pipefail

# THE REASON STRING IS NOT ALWAYS THIS FILE'S OWN PROSE. It can carry a value read from the
# repository or from the tool call -- an account name out of a profile, a tool suffix off the
# invocation -- and a backslash, a quote or a control character in one of those turns the hand-
# built JSON into malformed JSON. The caller then cannot read the decision, so a DENY that was
# correctly reached is a deny that does not arrive. Let jq do the escaping; it is already a hard
# dependency of both guards.
emit() {
  if command -v jq >/dev/null 2>&1; then
    jq -cn --arg d "$1" --arg r "$2" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  else
    # jq missing is itself one of the deny paths, and it is reached BEFORE any dynamic value is
    # read, so the only text arriving here is this guard's own static prose. Quote-strip anyway,
    # with bash parameter expansion rather than `tr`: this branch runs precisely when the PATH is
    # impoverished, and a fallback that shells out to another tool emits empty strings instead of
    # a decision when that tool is missing too. It did exactly that when first written.
    local d="${1//[\\\"]/}" r="${2//[\\\"]/}"
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$d" "$r"
  fi
  exit 0
}
deny() { emit "deny" "$1"; }
trap 'emit "deny" "no-outward-send guard crashed (fail-closed). Nothing was sent. See .claude/rules/no-outward-send.md and CLAUDE.md 6."' ERR

RULE="See .claude/rules/no-outward-send.md and CLAUDE.md 6."

# --- The governance-publishing declaration ----------------------------
#
# ONE way past the Confluence PAGE deny, and nothing else moves. A governance
# document -- a data-flow register, a security dossier, a control description --
# is written to be read by colleagues, so withholding it forever is not the
# right answer either. What the deny is actually for is the page nobody asked
# for: a session deciding on its own to put a document under the operator's name
# in a space their colleagues read.
#
# So the route is a DECLARATION, in the shape gitops-via-skills.sh already
# established: the caller names the skill it is acting as, and that name lands
# in the record. Read that file's header for the reasoning; the short version is
# that a declaration stops the ACCIDENTAL publish, which is the one that
# actually happens, while a deliberate override stays possible and stays
# visible. This is NOT a claim that the guard cannot be talked past.
#
# WHY THIS ONE IS READ FROM THE ENVIRONMENT AND NOT FROM THE TOOL CALL. SCT_VIA
# rides on a command line, and an MCP tool call has no command line. Nor can the
# declaration be smuggled into the payload: createConfluencePage and
# updateConfluencePage both declare additionalProperties:false, so an invented
# field is not accepted, and the only fields that WOULD carry it (title, body)
# are the published document itself. A declaration that prints itself into the
# page it authorises is not a control, it is a footer.
#
# What is left is the hook's own environment, which the CLI hands down from the
# session. That has a property worth naming: a Bash `export` inside a session
# does not reach the parent process, so a session cannot mint this for itself
# mid-flight the way it can type a command-line prefix. The grant is made when
# the session is started, by the operator, and it lasts the session. That is a
# STANDING grant rather than a per-page one -- weaker than an out-of-band
# approval per document, stronger than a prefix any caller can type. Recorded
# here so the next reader knows which was chosen and does not mistake it for
# the stronger thing.
GOV_DOC_SKILLS='sc-publish-gov-doc'

# The declaration must look like a declaration: exact equality against the
# allowlist, never a substring. `SCT_VIA=sc-publish-gov-doc-lol` is not it, and
# neither is an empty value. Same lesson as gitops-via-skills.sh line 182.
gov_doc_declared() {
  local v="${SCT_VIA:-}"
  [ -n "$v" ] || return 1
  grep -qxE "(${GOV_DOC_SKILLS})" <<<"$v"
}

# --- The register-operator declaration --------------------------------
#
# A SECOND declared route, in the same shape as the first: read from the hook's
# own environment, so it is granted by the operator when the session is launched
# and cannot be minted from inside it.
#
# What it is for. A security function that keeps its registers in Jira and runs
# its incidents in Slack asks a session for a stream of small writes: an item
# created, a comment appended, a stage moved, a private channel opened, an
# announcement posted. Under the default deny the operator makes every one by
# hand from text the session prepares. The declaration lets the session that
# keeps the record make them, as the operator and on the operator's instruction.
#
# THE VALUE IS A ROLE, NOT A PROJECT'S SKILL NAME. This file is shared by every
# repository on the machine and carries none of their names, keys or channels. A
# repository that operates registers says in its own manifest which of its
# skills act under this declaration and what each may do with it. The projects
# are named by the operator at launch, never here.
#
# WHAT IT OPENS, AND NOTHING ELSE.
#
# In Slack:
#   slack_create_conversation  - a PRIVATE CHANNEL only. A channel_name is
#                                required and is_private must be boolean true. A
#                                DM or group DM (user_ids with no channel_name)
#                                and a public channel stay denied.
#   slack_send_message         - to a CHANNEL only. A channel_id that is a user
#                                id or a DM id stays denied, declared or not: a
#                                message to a person is never operating a register.
#
# In Jira, and only in the projects the operator lists at launch in a second
# variable, SCT_JIRA_PROJECTS (comma-separated plain keys, e.g. ROR,INC,SEC):
#   createJiraIssue            - projectKey equal to one of the listed keys.
#   editJiraIssue              - issueIdOrKey of the form <KEY>-<digits>, KEY listed.
#   transitionJiraIssue        - the same.
#   addOrEditJiraIssueComment  - the same, AND no commentId: a new comment is an
#                                append, an edit of an existing one is forbidden
#                                by any register whose comments are evidence.
#
# WHAT IT DOES NOT OPEN: a delete of anything, an issue link (createIssueLink,
# createJiraIssueLink, createJiraIssueRemoteIssueLink), a worklog (addWorklogToJiraIssue,
# addOrEditJiraIssueWorklog), an attachment (uploadAttachmentToJiraIssue), a watch
# (watchJiraIssue), an entity property (editJiraEntityProperty), a change of issue
# hierarchy (convertJiraIssueHierarchy), a write to the shared catalogue or the
# graph (the Compass tools, addTeamworkGraphContext, addGraphContext), any project not listed, a numeric issue id in place of a key (the
# project cannot be read off it), scheduling, reactions, canvases, mail,
# calendar, Confluence, the generic execute runners (denied to everyone, below),
# and every shell route. The shell layer is untouched, so `curl chat.postMessage`
# and `acli jira workitem create` are denied to a declared session exactly as
# before. A project list that is not plain keys denies everything, so a
# malformed or empty variable opens nothing.
#
# HOW STRONG THIS IS, HONESTLY. In Jira the guard CAN hold the boundary: every
# write names its target, and the target is matched exactly against the list.
# In Slack it cannot: the guard sees a channel id, not a channel name, and has
# no way to know which channel is the incident's, so a declared session CAN post
# in any channel the operator's account can post in. There the skill that
# carries the declaration confines itself, and the operator who granted it is
# trusting that skill. What the guard holds in Slack, mechanically, is the line
# that matters most: no message to an individual, no DM, no public channel.
# Like the governance route this is a STANDING grant for the session.
OPERATOR_SKILLS='sc-register-operator'

operator_declared() {
  local v="${SCT_VIA:-}"
  [ -n "$v" ] || return 1
  grep -qxE "(${OPERATOR_SKILLS})" <<<"$v"
}

# The listed project keys as a jq array, if the operator listed any and every
# one is the plain Jira form. Returns 1 otherwise, and every caller then denies.
# Commas only: a space, a lower-case letter, a hyphen or a regex character
# anywhere makes the whole list invalid rather than partly valid.
named_projects() {
  local v="${SCT_JIRA_PROJECTS:-}"
  [ -n "$v" ] || return 1
  grep -qxE '[A-Z][A-Z0-9]{1,9}(,[A-Z][A-Z0-9]{1,9})*' <<<"$v" || return 1
  jq -cn --arg v "$v" '$v | split(",")'
}

# <KEY>-<digits>, the whole string, for a listed KEY. jq anchors with \A and
# \z: grep -x matches per line and let a second line through once already.
in_named_project() { # in_named_project <jq path to the key field>
  local ks; ks=$(named_projects) || return 1
  # `$ks[] as $p` binds the project; inside `select($k | test(...))` a bare `.`
  # would be the key, not the project, which is how the first version denied
  # every key and its own positive tests caught it.
  jq -e --argjson ks "$ks" "$1"' as $k | ($k | type) == "string" and ([$ks[] as $p | select($k | test("\\A" + $p + "-[0-9]+\\z"))] | length) > 0' >/dev/null 2>&1 <<<"$payload"
}

# --- 0. Parse, or deny ------------------------------------------------

payload=$(cat 2>/dev/null || true)
[ -n "$payload" ] || deny "Refused: the no-outward-send guard received no input and cannot tell what tool was asked for, so it denies. $RULE"

command -v jq >/dev/null 2>&1 || deny "Refused: the no-outward-send guard needs jq to read its input and jq is missing, so it denies rather than guessing. Install it (brew install jq). $RULE"

jq -e 'type == "object"' >/dev/null 2>&1 <<<"$payload" || deny "Refused: the no-outward-send guard could not parse its input as a tool call, so it denies. $RULE"

tool=$(jq -r '.tool_name // ""' <<<"$payload")
[ -n "$tool" ] || deny "Refused: the no-outward-send guard received a tool call with no tool name and cannot tell whether it sends, so it denies. $RULE"

# MCP server ids are unstable hashes. Everything after the final __ is the tool.
suffix="${tool##*__}"

# --- 1. Tool name layer -----------------------------------------------

case "$suffix" in

  slack_create_conversation)
    # Default deny. Declared: a private channel, and only that. Both reads are
    # exact: a missing channel_name is a DM, and anything but boolean true for
    # is_private, including the string "true" and an absent key, is not private.
    if operator_declared; then
      chname=$(jq -r '.tool_input.channel_name // "" | if type == "string" then . else "" end' <<<"$payload")
      priv=$(jq -r 'if .tool_input.is_private == true then "yes" else "no" end' <<<"$payload")
      [ -n "$chname" ] || deny "Refused: '$suffix' with no channel_name opens a direct message, and the register-operator declaration does not reach a message to a person. It opens a private channel and nothing else. $RULE"
      [ "$priv" = "yes" ] || deny "Refused: '$suffix' would create a channel that is not private. The register-operator declaration opens a PRIVATE channel only: is_private must be true. $RULE"
    else
      deny "Refused: '$suffix' puts something into Slack where other people see it. This repository drafts Slack messages and the operator sends them. Use slack_send_message_draft, or write the draft into the repository for approval. If you are a register-operator skill, the session must carry the declaration in its environment: SCT_VIA=sc-register-operator. It cannot be set from inside the session. Reading and searching Slack are unaffected. $RULE"
    fi ;;

  slack_send_message)
    # Default deny. Declared: a channel, never a person. Slack channel ids begin
    # C (a public or private channel) or G (a legacy private group); a user id
    # begins U or W and a DM id begins D. Anything else, an empty id and a
    # lower-case one included, denies.
    #
    # THE TEST IS DONE IN jq, ANCHORED WITH \A AND \z, NOT WITH grep -x. grep
    # matches per LINE, so a value carrying a user id on one line and a channel
    # id on the next satisfied `grep -x` on its second line and was allowed. The
    # first version of this branch did exactly that and its own negative test
    # caught it. \A and \z anchor the whole string; ^ and $ would not, because
    # they are line anchors in jq's regex engine as well.
    if operator_declared; then
      if ! jq -e '.tool_input.channel_id | type == "string" and test("\\A[CG][A-Z0-9]{2,}\\z")' >/dev/null 2>&1 <<<"$payload"; then
        deny "Refused: '$suffix' is not addressed to a channel. The register-operator declaration reaches a channel and nothing else; a message to an individual stays the operator's to send. $RULE"
      fi
    else
      deny "Refused: '$suffix' puts something into Slack where other people see it. This repository drafts Slack messages and the operator sends them. Use slack_send_message_draft, or write the draft into the repository for approval. If you are a register-operator skill, the session must carry the declaration in its environment: SCT_VIA=sc-register-operator. It cannot be set from inside the session. Reading and searching Slack are unaffected. $RULE"
    fi ;;

  slack_schedule_message|slack_add_reaction|slack_create_canvas|slack_update_canvas)
    # NOT covered by the incident declaration, deliberately. A scheduled message
    # sends when nobody is watching, and no incident step needs a reaction or a
    # canvas.
    deny "Refused: '$suffix' puts something into Slack where other people see it. This repository drafts Slack messages and the operator sends them. Use slack_send_message_draft, or write the draft into the repository for approval. Reading and searching Slack are unaffected. $RULE" ;;

  send_message|reply|forward)
    deny "Refused: '$suffix' sends mail. Draft it instead with create_draft or update_draft and leave it for the operator to send. Note that this denial is on the tool name alone, so it applies to every connector offering a tool by that name, which is deliberate. $RULE" ;;

  trash_message|trash_thread|mark_message_spam|mark_thread_spam)
    deny "Refused: '$suffix' is irreversible and visible outside this machine. It is not sending, but it is the same class of act: an agent changing the state of a real mailbox without a person deciding to. Label it or report it instead. $RULE" ;;

  create_event|update_event|delete_event|respond_to_event)
    deny "Refused: '$suffix' mails the attendees. A calendar write is a message to everyone on the invitation, so it is a send. Propose the slot in a draft and let the operator issue the invitation. list_events, search_events, get_event and suggest_time are unaffected. $RULE" ;;

  send_imessage)
    deny "Refused: '$suffix' sends a message as the operator from their own devices. Draft the text and let them send it. $RULE" ;;

  createEnvelope|createEnvelopeFromTemplate|sendReminder|triggerWorkflow)
    deny "Refused: '$suffix' puts a signature request or a chase in front of a counterparty. Agreements are a person's act and the commercial exposure of getting one wrong is not recoverable. $RULE" ;;

  # The Atlassian MCP server reaches the same Jira and Confluence that `acli`
  # does, over a different transport, so section 2c below cannot see it. A
  # comment, a transition, an assignment or a published page is a statement
  # about somebody's work made under the operator's own account; the tracker
  # rule that governs the shell route governs this one identically.
  #
  # These names are specific enough that suffix matching costs nothing here.
  # Unlike `reply` or `send_message`, no other connector plausibly offers a
  # tool called `transitionJiraIssue`, so this branch has none of the
  # deliberate over-denial the generic names carry.
  createJiraIssue)
    # Default deny. Declared, with projects listed at launch: a create in one of
    # them and no other. The projectKey is matched exactly against the list.
    if operator_declared && ks=$(named_projects) \
       && jq -e --argjson ks "$ks" '.tool_input.projectKey as $p | ($p | type) == "string" and ($ks | index($p)) != null' >/dev/null 2>&1 <<<"$payload"; then
      :
    else
      deny "Refused: '$suffix' writes to Jira. A create is a statement about somebody's work and it belongs to the operator, not to a session. The tracker rule binds the project whichever repository the session was opened in, and it binds the MCP route exactly as it binds 'acli jira workitem'. If you are a register-operator skill, the session must carry SCT_VIA=sc-register-operator and SCT_JIRA_PROJECTS=<KEY[,KEY]> in its environment, and the create must be in a listed project. Every Jira read is unaffected. $RULE"
    fi ;;

  editJiraIssue|transitionJiraIssue)
    # Default deny. Declared: an issue of the named project, by key, and no other.
    if operator_declared && in_named_project '.tool_input.issueIdOrKey'; then
      :
    else
      deny "Refused: '$suffix' writes to Jira. An edit or a transition is a statement about somebody's work and it belongs to the operator, not to a session. If you are a register-operator skill, the session must carry SCT_VIA=sc-register-operator and SCT_JIRA_PROJECTS=<key>, and the issue must be named by a key in that project. Every Jira read is unaffected. $RULE"
    fi ;;

  addOrEditJiraIssueComment)
    # Default deny. Declared: a NEW comment on an issue of the named project. An
    # edit (commentId present) is denied whatever is declared: a register whose
    # comments are evidence is append-only, and the guard holds that line rather
    # than trusting the skill to.
    if operator_declared && in_named_project '.tool_input.issueIdOrKey' \
       && jq -e '.tool_input | has("commentId") | not' >/dev/null 2>&1 <<<"$payload"; then
      :
    else
      deny "Refused: '$suffix' writes to Jira. A comment is a statement about somebody's work and it belongs to the operator, not to a session; an edit of an existing comment is denied to every session, declared or not, because a register's comments are evidence and evidence is append-only. If you are a register-operator skill, the session must carry SCT_VIA=sc-register-operator and SCT_JIRA_PROJECTS=<key>, the issue must be in that project, and no commentId may be set. $RULE"
    fi ;;

  addCommentToJiraIssue|addWorklogToJiraIssue|createIssueLink|addOrEditJiraIssueWorklog|createJiraIssueLink|createJiraIssueRemoteIssueLink|uploadAttachmentToJiraIssue|watchJiraIssue|editJiraEntityProperty|convertJiraIssueHierarchy)
    # The connector renamed several of these after this branch was written, and
    # the old spellings are kept because it may present either: addWorklogToJiraIssue
    # is now addOrEditJiraIssueWorklog, createIssueLink is now createJiraIssueLink,
    # and addCommentToJiraIssue is now addOrEditJiraIssueComment (handled above,
    # with its append-only declared route). The rest are write tools the connector
    # added and this guard had never heard of: a remote link to an outside URL, an
    # attachment, a watch (it subscribes the operator, or someone they name, to an
    # issue's mail), an entity property (a hidden field other tooling reads), and a
    # hierarchy conversion (it changes what an issue IS, and what sits under it).
    # None is opened by the register-operator declaration, so none gets an
    # exception here: denied to every session, declared or not.
    deny "Refused: '$suffix' writes to Jira. A comment, a link, a worklog, an attachment, a watch, a property or a change of issue type is a statement about somebody's work and it belongs to the operator, not to a session. The tracker rule binds the project whichever repository the session was opened in, and it binds the MCP route exactly as it binds 'acli jira workitem'. Every Jira read (search, get, transitions listing, metadata) is unaffected. $RULE" ;;

  executeWrite|executeDestructive)
    # The Atlassian server's generic runners take an operation NAME and run it.
    # They reach every write above, and every write this file has never heard
    # of, under one tool name the suffix layer could not see until 2026-10-13.
    # Denied to everyone, declared or not: a declared route is a named tool with
    # a shape the guard can read, and a runner that takes any operation is not.
    # executeRead and discover are reads and stay open.
    deny "Refused: '$suffix' runs an arbitrary Atlassian write or delete by operation name, which this guard cannot inspect. It is denied to every session, including a declared one: the declared routes are the named tools, whose inputs the guard reads. Use createJiraIssue, editJiraIssue, transitionJiraIssue or addOrEditJiraIssueComment under the declaration, or leave the act to the operator. executeRead and discover are unaffected. $RULE" ;;

  createConfluencePage|updateConfluencePage|createConfluenceContent|updateConfluenceContent)
    # A page is a document with the operator's name on it, so the default is
    # still deny. The declared route above is the exception, and it is the only
    # one: comments fall through to the branch below and do not get it.
    #
    # createConfluenceContent and updateConfluenceContent are the connector's
    # current primary tools and replaced the two Page names; both spellings are
    # kept because it may present either. They are WIDER than the tools they
    # replaced: createConfluenceContent also makes whiteboards, databases,
    # embeds, smart links, folders and slides, and updateConfluenceContent can
    # transfer a page's ownership (ownerId). The declaration is given plain
    # parity with the Page names anyway, by the operator's decision of
    # 2026-10-23 (PR 168). It stays a standing grant to the one skill the
    # operator launches, and that skill, not this guard, confines what it
    # publishes. A declared session can therefore reach the wider surface
    # through these two names; an undeclared one reaches none of it.
    if gov_doc_declared; then
      :
    else
      deny "Refused: '$suffix' publishes into Confluence, where colleagues read it and where it is attributed to the operator. A page is a document with their name on it. Draft it in the working tree and let the operator publish. If you are the governance-publishing skill, the session must carry the declaration in its environment: SCT_VIA=sc-publish-gov-doc. It cannot be set from inside the session. Reading and searching Confluence are unaffected. $RULE"
    fi ;;

  createConfluenceFooterComment|createConfluenceInlineComment)
    # NOT covered by the declaration, deliberately. Publishing a governance
    # document the operator asked for is one act; speech in the margin of
    # somebody else's page is a different one, and no gov-doc workflow needs it.
    deny "Refused: '$suffix' is speech in somebody else's space, attributed to the operator. The governance-publishing declaration does not reach this: it authorises a document, not a remark on someone's page. Put the text in the working tree. Reading comments is unaffected. $RULE" ;;

  createCompassComponent|createCompassComponentRelationship|createCompassCustomFieldDefinition|addTeamworkGraphContext|addGraphContext)
    deny "Refused: '$suffix' writes to the shared Atlassian catalogue that other teams read as a description of the estate. It is not a message, but it is the same class of act: a session changing a record other people rely on without a person deciding to. $RULE" ;;

esac

# --- 2. Shell layer ---------------------------------------------------
#
# Read the command from any tool that carries one, not just Bash, so a
# differently named command runner does not walk straight past this.

cmd=$(jq -r '.tool_input.command // ""' <<<"$payload")

# A command position: start of line, or after ; & | && || ( or a backtick.
POS='(^|[;&|(`]|&&|\|\|)[[:space:]]*'
# The bare NAME=value form belongs here with sudo and env, because it is how a shell
# actually accepts per-command environment. Without it there was no command position
# left for POS to match after the assignment, so `FOO=bar <anything>` walked past the
# WHOLE shell layer -- not just the gh rules but the curl send rules too.
#
# The sharp edge was the sibling guard: gitops-via-skills tells operators to write
# exactly `SCT_VIA=<skill> gh ...`, so following one guard's documented instructions
# silently disabled this one. Regression cases live in test-no-outward-send.sh.
PRE='(sudo[[:space:]]+|env[[:space:]]+[^[:space:]]+=[^[:space:]]*[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*'

if [ -n "$cmd" ]; then

  http_client=0
  if grep -qE "${POS}${PRE}(curl|wget|http|https|httpie|xh|lwp-request)([[:space:]]|$)" <<<"$cmd"; then
    http_client=1
  fi

  if [ "$http_client" = 1 ]; then

    # 2a. Endpoints that exist only to send. No method check needed.
    if grep -qiE 'chat\.postMessage|chat\.scheduleMessage|chat\.postEphemeral|chat\.meMessage|chat\.update|chat\.delete|hooks\.slack\.com/services|files\.upload|conversations\.invite|conversations\.create|messages/send|drafts/send|sendMail' <<<"$cmd"; then
      deny "Refused: this is an HTTP call to a send endpoint. Reaching Slack or mail through curl is the same act as reaching it through the connector, and the guard treats it the same way. Reads against the same APIs are allowed. $RULE"
    fi

    # 2b. Any mutating call against a messaging or agreement API.
    if grep -qiE 'slack\.com/api/|hooks\.slack\.com|gmail\.googleapis\.com|googleapis\.com/gmail|googleapis\.com/calendar|calendar\.googleapis\.com|graph\.microsoft\.com|docusign\.(net|com)' <<<"$cmd"; then
      if grep -qE '(-X|--request)[[:space:]]*(POST|PUT|PATCH|DELETE)|--data|(^|[[:space:]])-d([[:space:]]|$)|--form|(^|[[:space:]])-F([[:space:]]|$)|--post-data|--upload-file|(^|[[:space:]])-T([[:space:]]|$)' <<<"$cmd"; then
        deny "Refused: this is a write against a messaging, calendar or agreement API. A GET against the same host is fine and is how this repository is meant to read. $RULE"
      fi
    fi

    # 2b-bis. Atlassian over HTTP. THIS SECTION IS THE REASON THE ONE ABOVE IT
    # IS NOT ENOUGH.
    #
    # The tool-name layer denies createConfluencePage and the Jira write tools,
    # and 2c denies `acli jira workitem` writes. Neither sees curl. Until this
    # existed, `curl -X POST .../wiki/api/v2/pages` reached the same Confluence
    # with the same authority and met no layer at all -- the tool-name deny was
    # a door with a wall beside it. That is the state this file's header calls
    # the worst a control can be in, and adding a declared route to the MCP
    # branch without closing this would have advertised a gate that did not
    # hold.
    #
    # The declaration is honoured here too, and here it genuinely is a command
    # line, so it is spelled the way gitops-via-skills.sh spells one. It only
    # opens Confluence CONTENT paths: a declared publish is still not a licence
    # to write Jira, move a space or change permissions.
    if grep -qiE 'atlassian\.net|atlassian\.com/ex/(jira|confluence)' <<<"$cmd"; then
      if grep -qE '(-X|--request)[[:space:]]*(POST|PUT|PATCH|DELETE)|--data|(^|[[:space:]])-d([[:space:]]|$)|--form|(^|[[:space:]])-F([[:space:]]|$)|--post-data|--upload-file|(^|[[:space:]])-T([[:space:]]|$)' <<<"$cmd"; then

        declared_here=0
        if grep -qE "(^|[;&|(\`]|&&|\|\|)[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*SCT_VIA=(${GOV_DOC_SKILLS})[[:space:]]" <<<"$cmd"; then
          declared_here=1
        fi
        # A Confluence page write, and only that. Jira REST, space admin and
        # permission paths are not content and never ride the declaration.
        page_path=0
        if grep -qiE '/wiki/(api/v2/(pages|blogposts)|rest/api/content)' <<<"$cmd"; then
          page_path=1
        fi

        if [ "$declared_here" = 1 ] && [ "$page_path" = 1 ]; then
          :
        elif [ "$page_path" = 1 ]; then
          deny "Refused: this is an HTTP write to a Confluence page, which is the same act as createConfluencePage spelled differently, and the guard treats it the same way. If you are the governance-publishing skill, declare it on the command line: SCT_VIA=sc-publish-gov-doc curl ... GETs against the same host are unaffected. $RULE"
        else
          deny "Refused: this is an HTTP write to Atlassian. A Jira write is a statement about somebody's work and a space or permission change alters what colleagues can see; both belong to the operator. The governance-publishing declaration does not reach either -- it authorises a Confluence page and nothing else. Reads are unaffected. $RULE"
        fi
      fi
    fi
  fi

  # 2c. Jira writes. A Jira write is a person's act.
  if grep -qE "${POS}${PRE}acli[[:space:]]+jira[[:space:]]+workitem[[:space:]]+(comment|transition|assign|create|edit|delete)([[:space:]]|$)" <<<"$cmd"; then
    deny "Refused: 'acli jira workitem' write. Comments, transitions and assignments are statements about somebody's work and they belong to the operator, not to a session. See the repository's own jira-write-safety rule, which binds the tracker project whichever repository the session was opened in. acli jira workitem search and view are unaffected. $RULE"
  fi

  # 2d. AppleScript driving Mail or Messages.
  if grep -qE "${POS}${PRE}osascript([[:space:]]|$)" <<<"$cmd"; then
    if grep -qiE '\b(Mail|Messages|iMessage)\b' <<<"$cmd" \
       && grep -qiE 'send|deliver|outgoing message|reply|forward' <<<"$cmd"; then
      deny "Refused: this is osascript driving Mail or Messages to send. The route is different, the act is identical. $RULE"
    fi
  fi

  # 2e. Outward speech in someone else's repository.
  if grep -qE "${POS}${PRE}gh[[:space:]]+((pr|issue)[[:space:]]+comment|pr[[:space:]]+review)([[:space:]]|$)" <<<"$cmd"; then
    deny "Refused: 'gh pr comment', 'gh issue comment' and 'gh pr review' are published speech attributed to the operator in a repository other people read. Put the text in the working tree and let them post it. gh reads are unaffected. $RULE"
  fi
  # Scope the test to the `gh api` invocation itself, not to the whole command.
  #
  # An earlier version tested all three conditions against $cmd as a whole, so a
  # compound command containing a harmless `gh api` read was denied whenever
  # something ELSEWHERE in it happened to supply a field flag and the word
  # "review". A commit whose message mentioned a review did exactly that on
  # 2026-08-27, and the same command then blocked its own repair.
  #
  # Over-denial is the safe direction, but not when it blocks ordinary work the
  # guard was never meant to reach. The three conditions must hold within one
  # command segment to mean anything.
  #
  # Segmentation is by shell operator only. It does not parse quoting or
  # heredocs, so a single segment carrying all three conditions inside quoted
  # text is still denied. That residual over-denial is deliberate: understanding
  # shell quoting is not a job for a guard that must fail closed.
  gh_api_segment="$(printf '%s' "$cmd" \
    | tr ';&|' '\n' \
    | grep -E "(^|[[:space:]])gh[[:space:]]+api([[:space:]]|$)" || true)"
  if [ -n "$gh_api_segment" ] \
     && grep -qE '(-X|--method)[[:space:]]*(POST|PUT|PATCH|DELETE)|(^|[[:space:]])(-f|-F|--field|--raw-field)([[:space:]]|$)' <<<"$gh_api_segment" \
     && grep -qiE 'comment|review' <<<"$gh_api_segment"; then
    deny "Refused: this is 'gh api' posting to a comment or review endpoint, which is the same act as gh pr comment spelled differently. $RULE"
  fi

  # 2f. Google Workspace CLI (`gws`). The same acts, a different binary.
  #
  # gws holds its OWN OAuth session, so it reaches Gmail, Calendar, Chat and Drive
  # without touching a connector and without touching curl. Neither of the layers
  # above sees it: the tool-name layer only knows MCP suffixes, and 2a/2b only fire
  # on an HTTP client. Until this section existed, `gws gmail +send` was an open
  # route to a real mailbox from every session on the machine.
  #
  # DENYING ONLY THE `+` HELPERS WOULD BE THE WORSE KIND OF GUARD. The helpers are
  # conveniences over `users.messages.send` and `users.drafts.send`; a guard that
  # stops the shorthand and passes the real method looks present and is not, which
  # this file's header names as the worst state a control can be in. Both go.
  if grep -qE "${POS}${PRE}gws([[:space:]]|$)" <<<"$cmd"; then

    # The `+` helpers whose entire purpose is to put mail in front of a person.
    if grep -qE '[[:space:]]\+(send|reply|reply-all|forward)([[:space:]]|$)' <<<"$cmd"; then
      deny "Refused: 'gws' mail helpers (+send, +reply, +reply-all, +forward) send mail as the operator from their own account. Draft it instead with 'gws gmail users drafts create', which is untouched, and leave it for them to send. $RULE"
    fi

    # The API methods the helpers wrap, plus the destructive mailbox verbs that
    # sit in the same class as the connector's trash and spam tools.
    if grep -qE '(messages|drafts|threads)[[:space:]]+(send|insert|import|delete|batchDelete|trash)([[:space:]]|$)' <<<"$cmd"; then
      deny "Refused: this is a 'gws' send or destructive mailbox call. 'send' and 'insert' put mail in front of somebody; 'delete', 'batchDelete' and 'trash' change the state of a real mailbox without a person deciding to. Reads (list, get) and drafting (drafts create, drafts update) are unaffected. $RULE"
    fi

    # A calendar write mails every attendee. Same reasoning as the connector layer.
    if grep -qE '(events|acl)[[:space:]]+(insert|update|patch|delete|import|move|quickAdd)([[:space:]]|$)' <<<"$cmd"; then
      deny "Refused: a 'gws' calendar write mails everyone on the invitation, so it is a message that happens to look like a data change. events list, get and instances are unaffected. $RULE"
    fi

    # Chat posts are published speech; a Drive permission grant hands a client
    # document to somebody and emails them to say so.
    if grep -qE '(spaces[[:space:]]+messages|permissions)[[:space:]]+(create|update|patch|delete)([[:space:]]|$)' <<<"$cmd"; then
      deny "Refused: this is a 'gws' Chat post or Drive permission change. Both are outward: one is speech attributed to the operator, the other hands a document to somebody and mails them about it. Reads are unaffected. $RULE"
    fi
  fi
fi

# --- 3. AppleScript reached through a connector rather than the shell ---
#
# The osascript connector runs the same AppleScript as the shell does, so the
# same test applies to its script text. Reading Mail or Messages is untouched.

if [ "$suffix" = "osascript" ]; then
  blob=$(jq -r '[.tool_input | .. | strings] | join(" ")' <<<"$payload" 2>/dev/null || echo "")
  if [ -n "$blob" ] \
     && grep -qiE '\b(Mail|Messages|iMessage)\b' <<<"$blob" \
     && grep -qiE 'send|deliver|outgoing message|reply|forward' <<<"$blob"; then
    deny "Refused: this AppleScript drives Mail or Messages to send. Reaching them through the osascript connector is the same act as reaching them through the shell. $RULE"
  fi
fi

exit 0
