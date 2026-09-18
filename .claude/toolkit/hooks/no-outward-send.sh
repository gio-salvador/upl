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
# THE ONE DECLARED ROUTE. Everything above is denied outright. A Confluence PAGE
# is the single exception: it is denied by default and allowed when the caller
# declares itself as the governance-publishing skill. The reasoning, the shape
# of the declaration, and an honest account of how strong it is and is not are
# recorded at GOV_DOC_SKILLS below. Read that before widening it. The exception
# covers a page and stops there -- not a comment, not Jira, not a space, not a
# permission -- and the tests assert each of those boundaries by name, because
# the way a narrow exception fails is by quietly becoming a general one.
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
  printf '%s' "$v" | grep -qxE "(${GOV_DOC_SKILLS})"
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

  slack_send_message|slack_schedule_message|slack_add_reaction|slack_create_canvas|slack_update_canvas|slack_create_conversation)
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
  createJiraIssue|editJiraIssue|transitionJiraIssue|addCommentToJiraIssue|addWorklogToJiraIssue|createIssueLink)
    deny "Refused: '$suffix' writes to Jira. A comment, a transition, an assignment or a worklog is a statement about somebody's work and it belongs to the operator, not to a session. The tracker rule binds the project whichever repository the session was opened in, and it binds the MCP route exactly as it binds 'acli jira workitem'. Every Jira read (search, get, transitions listing, metadata) is unaffected. $RULE" ;;

  createConfluencePage|updateConfluencePage)
    # A page is a document with the operator's name on it, so the default is
    # still deny. The declared route above is the exception, and it is the only
    # one: comments fall through to the branch below and do not get it.
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

  createCompassComponent|createCompassComponentRelationship|createCompassCustomFieldDefinition|addTeamworkGraphContext)
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
  if printf '%s' "$cmd" | grep -qE "${POS}${PRE}(curl|wget|http|https|httpie|xh|lwp-request)([[:space:]]|$)"; then
    http_client=1
  fi

  if [ "$http_client" = 1 ]; then

    # 2a. Endpoints that exist only to send. No method check needed.
    if printf '%s' "$cmd" | grep -qiE 'chat\.postMessage|chat\.scheduleMessage|chat\.postEphemeral|chat\.meMessage|chat\.update|chat\.delete|hooks\.slack\.com/services|files\.upload|conversations\.invite|conversations\.create|messages/send|drafts/send|sendMail'; then
      deny "Refused: this is an HTTP call to a send endpoint. Reaching Slack or mail through curl is the same act as reaching it through the connector, and the guard treats it the same way. Reads against the same APIs are allowed. $RULE"
    fi

    # 2b. Any mutating call against a messaging or agreement API.
    if printf '%s' "$cmd" | grep -qiE 'slack\.com/api/|hooks\.slack\.com|gmail\.googleapis\.com|googleapis\.com/gmail|googleapis\.com/calendar|calendar\.googleapis\.com|graph\.microsoft\.com|docusign\.(net|com)'; then
      if printf '%s' "$cmd" | grep -qE '(-X|--request)[[:space:]]*(POST|PUT|PATCH|DELETE)|--data|(^|[[:space:]])-d([[:space:]]|$)|--form|(^|[[:space:]])-F([[:space:]]|$)|--post-data|--upload-file|(^|[[:space:]])-T([[:space:]]|$)'; then
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
    if printf '%s' "$cmd" | grep -qiE 'atlassian\.net|atlassian\.com/ex/(jira|confluence)'; then
      if printf '%s' "$cmd" | grep -qE '(-X|--request)[[:space:]]*(POST|PUT|PATCH|DELETE)|--data|(^|[[:space:]])-d([[:space:]]|$)|--form|(^|[[:space:]])-F([[:space:]]|$)|--post-data|--upload-file|(^|[[:space:]])-T([[:space:]]|$)'; then

        declared_here=0
        if printf '%s' "$cmd" | grep -qE "(^|[;&|(\`]|&&|\|\|)[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*SCT_VIA=(${GOV_DOC_SKILLS})[[:space:]]"; then
          declared_here=1
        fi
        # A Confluence page write, and only that. Jira REST, space admin and
        # permission paths are not content and never ride the declaration.
        page_path=0
        if printf '%s' "$cmd" | grep -qiE '/wiki/(api/v2/(pages|blogposts)|rest/api/content)'; then
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
  if printf '%s' "$cmd" | grep -qE "${POS}${PRE}acli[[:space:]]+jira[[:space:]]+workitem[[:space:]]+(comment|transition|assign|create|edit|delete)([[:space:]]|$)"; then
    deny "Refused: 'acli jira workitem' write. Comments, transitions and assignments are statements about somebody's work and they belong to the operator, not to a session. See the repository's own jira-write-safety rule, which binds the tracker project whichever repository the session was opened in. acli jira workitem search and view are unaffected. $RULE"
  fi

  # 2d. AppleScript driving Mail or Messages.
  if printf '%s' "$cmd" | grep -qE "${POS}${PRE}osascript([[:space:]]|$)"; then
    if printf '%s' "$cmd" | grep -qiE '\b(Mail|Messages|iMessage)\b' \
       && printf '%s' "$cmd" | grep -qiE 'send|deliver|outgoing message|reply|forward'; then
      deny "Refused: this is osascript driving Mail or Messages to send. The route is different, the act is identical. $RULE"
    fi
  fi

  # 2e. Outward speech in someone else's repository.
  if printf '%s' "$cmd" | grep -qE "${POS}${PRE}gh[[:space:]]+((pr|issue)[[:space:]]+comment|pr[[:space:]]+review)([[:space:]]|$)"; then
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
     && printf '%s' "$gh_api_segment" | grep -qE '(-X|--method)[[:space:]]*(POST|PUT|PATCH|DELETE)|(^|[[:space:]])(-f|-F|--field|--raw-field)([[:space:]]|$)' \
     && printf '%s' "$gh_api_segment" | grep -qiE 'comment|review'; then
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
  if printf '%s' "$cmd" | grep -qE "${POS}${PRE}gws([[:space:]]|$)"; then

    # The `+` helpers whose entire purpose is to put mail in front of a person.
    if printf '%s' "$cmd" | grep -qE '[[:space:]]\+(send|reply|reply-all|forward)([[:space:]]|$)'; then
      deny "Refused: 'gws' mail helpers (+send, +reply, +reply-all, +forward) send mail as the operator from their own account. Draft it instead with 'gws gmail users drafts create', which is untouched, and leave it for them to send. $RULE"
    fi

    # The API methods the helpers wrap, plus the destructive mailbox verbs that
    # sit in the same class as the connector's trash and spam tools.
    if printf '%s' "$cmd" | grep -qE '(messages|drafts|threads)[[:space:]]+(send|insert|import|delete|batchDelete|trash)([[:space:]]|$)'; then
      deny "Refused: this is a 'gws' send or destructive mailbox call. 'send' and 'insert' put mail in front of somebody; 'delete', 'batchDelete' and 'trash' change the state of a real mailbox without a person deciding to. Reads (list, get) and drafting (drafts create, drafts update) are unaffected. $RULE"
    fi

    # A calendar write mails every attendee. Same reasoning as the connector layer.
    if printf '%s' "$cmd" | grep -qE '(events|acl)[[:space:]]+(insert|update|patch|delete|import|move|quickAdd)([[:space:]]|$)'; then
      deny "Refused: a 'gws' calendar write mails everyone on the invitation, so it is a message that happens to look like a data change. events list, get and instances are unaffected. $RULE"
    fi

    # Chat posts are published speech; a Drive permission grant hands a client
    # document to somebody and emails them to say so.
    if printf '%s' "$cmd" | grep -qE '(spaces[[:space:]]+messages|permissions)[[:space:]]+(create|update|patch|delete)([[:space:]]|$)'; then
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
     && printf '%s' "$blob" | grep -qiE '\b(Mail|Messages|iMessage)\b' \
     && printf '%s' "$blob" | grep -qiE 'send|deliver|outgoing message|reply|forward'; then
    deny "Refused: this AppleScript drives Mail or Messages to send. Reaching them through the osascript connector is the same act as reaching them through the shell. $RULE"
  fi
fi

exit 0
