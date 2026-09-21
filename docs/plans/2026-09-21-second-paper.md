# Write a second, sourced paper that places the Unified Path of Light among the traditions it draws on

**Status: planned, not built.** Requested 2026-09-21. This file records the design, the
sequence and the open decisions, so "not yet" stays a decision rather than becoming forgetting.
No step has begun. Nothing in it is wording for the paper: the paper's words are the author's.

## What was asked for

In the author's words, on 2026-09-21: "create a plan to write another academic paper to be
published to complement the first one as per current version".

Read here as three things. A second paper, not a second edition of the first. One that
complements the founding paper in `paper/`, so it does what that paper does not. And one that
speaks for the teachings as they stand today under `content/`, after the decisions and the
source work of 18 to 21 September 2026, not as they stood when the founding paper was written.
If the author meant a revised edition of the founding paper, that is decision A1 below, and it
is cheaper to say so now than after step 3.

## Where things stand

Measured on `main` at `4027fd2`.

| | The founding paper | The teachings today |
| --- | --- | --- |
| Size | 24 pages, about 8,000 words | 81 pages under `content/`, about 13,000 words |
| Citations in the text | none; a list of 12 titles at the end | every statement about a tradition, a figure, a book or science rests on a row in [sources.md](../sources.md): 196 rows, S01 to S196 |
| How the traditions stand to each teaching | said in passing, mostly as agreement, and mostly through Islam in the ten core beliefs | the convergence map in [cross-reference.md](../cross-reference.md): over a hundred cells, each sourced, of which 17 are "resembles only" and 8 are "contrary" |
| Balance between traditions | Islam 40 per cent of mentions when first measured | no tradition above about 17 per cent; the whole-text cap is 25 |
| What God is | left open between a person and a principle | decided: impersonal, the source of light (D1) |
| Soul, consciousness, spirit, true image | used side by side, undefined | decided: one essence, several names (D4) |
| Where UPL parts from a tradition | one sentence, and it misdescribed Buddhism | stated openly: non-self (D3), original sin, the resurrection of the body, eternal punishment, a creator |
| Healing | "cautious engagement" with medicine | decided: UPL heals the spirit, medicine treats the body, never spiritual remedies alone (D2) |
| Knowledge, the arts and technology | a way of life | decided: they serve spiritual evolution (D5) |
| How UPL addresses a follower | "expects", eight times, unclear | decided: four registers, belief, invitation, aspiration, commitment (D6) |
| The reference list | 12 entries, three of them wrong as listed and one not a book | 24 entries, each checked against a catalogue |

The decisions are in [doctrine-decisions.md](../doctrine-decisions.md). What the table says: the
founding paper is a statement of the teaching by its author. It does not show its sources, it
does not say where UPL disagrees with anyone, and it does not meet the questions a scholar of
religion would put to a new synthesis. All the material to do those three things now exists in
this repository, and none of it is in a form a reader outside the repository can cite.

## Goals

1. **A paper that does what the founding paper does not.** It shows the sources, states the
   convergences and the disagreements in each tradition's own terms, and records what has been
   clarified since. Serves the request.
2. **Academic in the checkable sense.** In-text citations, a full reference list, a method
   section, a section on limitations and objections, and the author's position as founder
   stated on the first page. Every claim about another tradition, a figure, a book or science
   traces to a register row. Serves guardrails section 6 and the honest-claims rule.
3. **The paper never becomes a second source of the teaching.** `content/` stays canonical
   (locked decision 1). The paper reports the teachings at one pinned commit. Anything the
   paper wants to say that the teachings do not yet say goes into `content/` first, through the
   teaching steward and the author's approval, and only then into the paper.
4. **The traditions are described accurately and none is ranked or made the default lens**
   (locked decisions 6 and 8). The balance rules bind the paper as they bind a teaching.
5. **Every word is the author's or approved by the author** (locked decision 2). Drafts are
   proposals with ids; nothing enters the paper's source unapproved.
6. **Published where it can be found and cited.** On the site beside the founding paper, and in
   a public archive that gives it a permanent identifier (decision A4).
7. **The founding paper stays exactly as published.** It is the record of what was first
   written (tradition balance plan, decision B2).

Non-goals:

- **Not a second edition.** The founding paper is not revised, replaced or withdrawn.
- **Not peer review, yet.** Submitting to a journal is a separate decision with its own costs
  (decision A5). The plan ends with the paper published and citable, and leaves that door open.
- **No new doctrine through the side door.** The paper adds no belief, practice or observance.
- **Not an apologetic.** The paper does not argue that UPL is right and a tradition wrong. It
  says what each holds and where they part.
- **No wording written for search engines or language models** (locked decision 3).

## What already exists, and must not be rebuilt

| Need | Already present |
| --- | --- |
| The teachings, current and gated | `content/`, `bash scripts/check.sh` |
| The doctrinal decisions and the author's own words for each | [doctrine-decisions.md](../doctrine-decisions.md), D1 to D6 |
| Every source, with what it supports and its cautions | [sources.md](../sources.md), `scripts/check-sources.py` |
| How each tradition stands to each teaching, sourced | the convergence map in `scripts/content-index.json`, rendered in [cross-reference.md](../cross-reference.md) |
| The balance rules and the count | [doctrine-guardrails.md](../doctrine-guardrails.md) section 2, `scripts/check-doctrine.py` |
| Doctrine fidelity review, and proposals approved by id | `.claude/agents/upl-teaching-steward.md` |
| Multi-lens review with a bounded loop | `.claude/content-review.yaml` and the toolkit's content review, with the citation, domain-accuracy, ip, consistency, audience-reader, scaffold and editor lenses |
| Serving a PDF from the site | `site/scripts/sync-paper.mjs` copies all of `paper/`; `site/src/lib/site.ts` and `site/src/lib/structured-data.ts` describe the founding paper |
| The licence | `LICENSE` section A already covers `paper/**` under CC BY-SA 4.0 |
| A markdown to PDF converter on this machine | pandoc is installed. No PDF engine is (see "missing", item 2) |

## What is genuinely missing

1. **A content brief for the paper.** Surface, reader, voice, length, scaffold, disclosure
   surface, goal. The global rules ask for one before any content task.
2. **A source form and a build.** The founding paper exists only as a PDF. The second needs a
   text source under version control and a repeatable build to PDF. pandoc needs a PDF engine,
   and none is installed.
3. **A citation format.** The register is a table of links with ids, not bibliographic records.
   A reference list needs author, year, title, publisher or journal, and for web sources the
   date read. Nothing holds those fields today.
4. **Gate coverage.** `scripts/check-sources.py` looks at `content/**/*.md` and `docs/**/*.md`;
   `scripts/check-doctrine.py` counts only `content/`. Neither sees a paper source.
5. **A traceability table.** Nothing maps a doctrinal sentence in a paper to the page under
   `content/` that owns it, so goal 3 cannot be checked.
6. **A content type for the paper in the review manifest.** `.claude/content-review.yaml` has
   `teaching` and `repo_docs` only.
7. **The scholarly literature.** The register holds scriptures, the traditions' own bodies and
   some science. It holds almost nothing on the questions a scholar would ask of UPL: whether
   religions share a common core, how new syntheses are studied, what is owed when a practice
   is taken from a living people. Those sources have to be found, read and recorded first.
8. **A second entry on the site.** The layout, the structured data and `llms.txt` each name one
   paper.
9. **A way to cite the paper.** No permanent identifier, no citation file, no author
   identifier.

## The design

### What the paper is (goals 1, 2)

Working title, the author's to change: "The Unified Path of Light among the traditions:
sources, convergences and differences". A companion to the founding paper, by the same author,
under the same licence. Length band 7,000 to 9,000 words, close to the first.

Proposed scaffold. Each section names where its material already is.

| # | Section | Draws on | New sources needed |
| --- | --- | --- | --- |
| 0 | Title page, author note with the author's position as founder, abstract, keywords | the founding paper's form | none |
| 1 | Introduction: what the founding paper set out, what it left unsaid, what this paper adds | the table in "Where things stand" | none |
| 2 | Method: a canonical text, a source register, a convergence map with five relations (origin, inherits, holds independently, resembles only, contrary), and a balance count | [cross-reference.md](../cross-reference.md), [doctrine-guardrails.md](../doctrine-guardrails.md) | none |
| 3 | What has been clarified since the founding paper: D1, D4, D3, D2, D5, D6, each in the author's words with the reasoning | [doctrine-decisions.md](../doctrine-decisions.md) | none |
| 4 | Convergences: the ten core beliefs, each with the traditions that hold it and the source, as one table and a commentary | the convergence map | none |
| 5 | Differences: the "resembles only" and "contrary" cells, each in the tradition's own terms and with the diversity inside the tradition kept | the convergence map, Comparative Analysis | few |
| 6 | Science: what UPL takes from physics and the study of consciousness as analogy, and what it does not claim | the doctrine pages, S10 to S13, the References entries on physics and consciousness | some; blocked by W3, see cross-dependencies |
| 7 | UPL in the study of religion: the scholarly questions a synthesis has to answer | nothing yet | most of step 3 |
| 8 | Limitations and objections: the author is the founder; the map is one reader's reading; borrowing from living traditions; what is still unsourced | the register's cautions, the parked items | some |
| 9 | Conclusion | sections 3 to 8 | none |
| 10 | References, generated from the register | [sources.md](../sources.md) | none |

Sections 3 to 5 are the heart and need almost no new research: the work is done and is sitting
in tables. Sections 7 and 8 are what make it a paper a scholar would take seriously, and they
are where the new reading is.

### The paper reports the teaching and never makes it (goal 3)

- The paper's front matter pins one commit of `content/`. Every doctrinal statement in the
  paper is either a quotation from a page at that commit or a paraphrase the author approved.
- A traceability table sits beside the paper source: one row per doctrinal statement, with the
  section of the paper, the owner page under `content/`, and the decision id where there is
  one. A statement with no owner page is a blocker: it goes to the teaching steward as a
  proposed teaching first, or it leaves the paper.
- Under `paper/`, the PDF is the published thing and the source is its working form. The
  architecture page gains one sentence saying so, so that a reader does not take the source for
  a second copy of the teachings.

### Sources and citations (goals 2, 4)

- In the source, a claim is cited by register id, as the teachings and the docs already do. The
  build turns ids into author and year in the text and a reference list at the end.
- The bibliographic fields live in a new data file keyed by register id (not a new register:
  [sources.md](../sources.md) stays the one place a source is recorded, and the gate checks
  that every key in the data file is a live row). Only the sources the paper cites need
  fields, which will be a fraction of the 196.
- A retired row or a row marked "secondary" cannot be cited in the paper. The parked list of
  rows still awaiting a primary source (S04, S07, S67, S83, S86, S87) is cleared for any of them
  the paper needs, before the section that needs it is drafted.
- Every quotation is checked by eye against the page before the freeze, as the register's
  caution already asks. Quotations from translations still in copyright are kept short and
  the ip lens reviews the proportions; the public-domain and openly licensed translations in
  References are preferred where the wording serves equally.

### Gates (goals 3, 4)

Extended, never loosened, and no change to `scripts/doctrine-baseline.json` or the caps in
`scripts/doctrine-gate.json`:

- The source gate reads the paper source as a citing page and as a claim page.
- The doctrine gate reports the balance of the paper source as its own figure, separate from
  the whole-text figure for `content/`, against the same caps. The paper is not added to the
  teachings' count, which would move the author's baseline.
- A new small check holds the traceability table: every row's owner page exists at the pinned
  commit, and the pinned commit is an ancestor of `main`.
- All three run from `bash scripts/check.sh`, so `bash scripts/ci-local.sh` covers them.
- A `paper` content type joins `.claude/content-review.yaml` with the lenses scaffold,
  citation, domain-accuracy, ip, consistency (against the guardrails and against `content/`),
  audience-reader, titles and editor. The editor lens may fix typos and broken sentences only,
  as for a teaching.

### Build (goal 6)

Markdown source, pandoc, one PDF committed under `paper/` like the first, in the same page
style so the two read as a pair. The build is a local script and is not part of the site
build, so the site stays static and the Cloudflare build gains no dependency. The PDF engine is
decision A6. The site needs no client-side script and no change to the Content-Security-Policy.

### Site (goal 6)

A structural pull request, no teaching touched: the footer and the home page list both papers,
the structured data describes the second as a scholarly article by the same author, `llms.txt`
lists it, and the link, SEO and mobile checks cover the new link. The second paragraph of the
home page is already parked as the author's to write (S4 in the site review); the new link
waits for that wording or goes in the footer only.

### Publication (goal 6)

The site first, then a public research archive that issues a permanent identifier and accepts
CC BY-SA 4.0, with the author's ORCID. The deposit is made by the author from the author's own
account: an agent does not create accounts or publish under the author's name. The identifier
then comes back into the repository in a citation file at the root and on the site. The
archive's terms, its fit with the licence and how it handles versions are verified on its own
pages in step 7, before anything is relied on.

### Who does what

| Work | Who |
| --- | --- |
| The decisions, the title, the abstract, the author note, the conclusion, approval of every section by id | the author |
| Finding and recording literature, never inventing a reference, marking what could not be opened | research agents, as in the tradition balance plan, step 1 |
| Section drafts as proposals, in a scratch tree, with the gates run before the author is asked | Claude, under the memory rule "gate drafts before approval" |
| Doctrine fidelity of each draft | the `upl-teaching-steward` agent, review mode |
| The review loop | the toolkit's content review with the `paper` content type |
| The disclosure check before anything leaves the machine | the NDA check, surface `public` |

## Open decisions

All OPEN. Each carries a recommendation so the plan can move on the author's "go".

- **A1 OPEN: companion paper or second edition.** Recommendation: companion, as designed above.
  A second edition would restate what `content/` now says better than any PDF can, and would
  put two versions of the founding text in circulation.
- **A2 OPEN: the thesis.** Recommendation: the paper's centre is sections 4 and 5, that UPL can
  say precisely what it shares with each tradition and precisely where it parts, with sources,
  and that saying the second as plainly as the first is what separates a synthesis from a
  blend. The alternative centre is section 3, a doctrinal development paper; it is the easier
  paper and the less useful one to a reader outside UPL.
- **A3 OPEN: voice.** Recommendation: scholarly first person. "I" for the author's decisions and
  position, plain description for the traditions, the author's own recorded words quoted where
  a decision is reported. Not the devotional voice of the founding paper, which a reader of
  this paper can find in the founding paper.
- **A4 OPEN: where it is published.** Recommendation: the site and one open research archive
  with a permanent identifier, deposited by the author. Costs nothing and keeps the licence.
- **A5 OPEN: a peer-reviewed journal afterwards.** Recommendation: decide after publication,
  not before. Three things to weigh then, each to be verified and not assumed: many journals
  ask for a licence other than CC BY-SA or for first publication; open-access journals often
  charge a fee; and a founder writing on the founder's own religion is an insider account,
  which some journals welcome as such and others do not take.
- **A6 OPEN: the PDF engine.** Recommendation: install one small engine locally (Typst or
  Tectonic, each a single binary) and record the version in the build script. The alternative,
  pandoc to a word processor file and export by hand, matches how the first paper was probably
  made and is not repeatable.
- **A7 OPEN: when.** The repository is private and the site is not yet live
  ([launch readiness](2026-09-18-launch-readiness.md)). Recommendation: write now, publish only
  after the site is public, so the paper's links to the teachings resolve on the day it appears.
- **A8 OPEN: W3 first.** The two accuracy points on the doctrine pages, the hard problem of
  consciousness called "empirically-based" and the observer effect, are the author's to settle
  and are still parked. Recommendation: settle them as a wording pull request before step 5
  drafts section 6. Otherwise the paper either repeats a statement the site review has marked
  inaccurate, or says something the teachings do not.

## Sequence

One pull request per step. Each leaves `main` green under `bash scripts/ci-local.sh`.

| Step | Pull request | Needs from you | Status |
| --- | --- | --- | --- |
| 0 | This plan, reviewed with the plan review | read it; A1 | open |
| 1 | The brief and the decisions: the content brief, A1 to A8 recorded as taken, the scaffold fixed | A1 to A8 | not started |
| 2 | Scaffolding: the paper source tree with headings only, the build, the bibliographic data file, the three gate extensions, the `paper` content type, the sentence in the architecture page | the engine install (A6) | not started |
| 3 | Literature: register rows for sections 6, 7 and 8, and primary sources in place of any secondary row the paper will cite | nothing, unless a source has to be bought | not started |
| 4 | The annotated outline and the traceability table: for each section, the claims it will make, the owner page and the sources, no prose | approve the outline by section | not started |
| 5 | Drafts, in three batches, each a set of proposals with ids: sections 2 to 5; sections 6 to 8; sections 0, 1 and 9, which are the author's own | approve, change or decline by id | not started |
| 6 | Review loop to a bounded cap, quotations checked by eye, the freeze: commit pinned, PDF built and committed, version 1.0 | read the PDF whole, once | not started |
| 7 | Site wiring, then the disclosure check, then publication: deploy, the author's deposit, the identifier and the citation file back into the repository | the deposit; the ORCID | not started |

Step 3 can run beside step 2. Steps 4 and 5 cannot start before step 3 ends for the sections
that need new sources, and can start at once for sections 2 to 5.

## Cross-dependencies

| Edge | Why it is hard and not tidy |
| --- | --- |
| Step 1 before everything | A1 changes what is being written; A3 changes every sentence |
| Sources before wording (step 3 before 4 and 5) | The source gate refuses a claim without a row, and the rule is that the row comes first. A draft written ahead of its sources gets bent to fit them |
| A8 (W3) before section 6 | Goal 3: the paper cannot say about science what the teachings do not yet say |
| Inside step 2: the data file before the gate extension | The gate checks the data file's keys against the register; it cannot pass on an absent file |
| Inside step 5: the steward's review before the author is asked | The author should not spend an approval on a draft that contradicts a core belief |
| Inside step 6: the pin after the last wording pull request to `content/` | A pin taken earlier reports a text that has since moved |
| The launch plan before step 7 | The paper links to the teachings by URL; A7 |
| Inside step 7: the disclosure check before the deploy and before the deposit | A deposit with a permanent identifier cannot be taken back |

## Risks

- **The paper drifts into a second source of doctrine.** Survivable because of the pin, the
  traceability table and its gate, and the rule that a new statement goes to `content/` first.
- **A tradition is misdescribed in a permanent, citable document.** Worse than on a page, which
  can be corrected in a pull request. Survivable because every such claim carries a row with
  its caution, the domain-accuracy lens checks it live, the quotations are checked by eye, and
  the archive chosen in A4 has to allow a corrected version under the same identifier family;
  that is one of the things step 7 verifies.
- **An invented or half-remembered reference.** The failure that would cost the paper its
  standing. Survivable because research agents are told never to invent and to mark what they
  could not open, and the reference list is generated from rows a gate has checked, not typed.
- **The scholarly section turns into a defence of UPL, or ranks traditions.** Survivable
  because section 8 is in the scaffold from the start, the consistency lens treats ranking as a
  major, and the paper's balance is counted.
- **Quotation beyond what copyright allows.** Survivable: the ip lens, short quotations, open
  translations preferred.
- **Borrowing from living peoples.** The Hawaiian and indigenous material is the most exposed
  to the charge of appropriation. The paper says what the sources allow and no more, and
  section 8 names the question instead of avoiding it. This is a risk accepted in part: the
  paper cannot settle it, only state it honestly.
- **The author's time.** Step 5 is the largest reading task since the core beliefs were
  rewritten. Three batches, each reviewable in one sitting, is the mitigation. There is no
  deadline, which is a decision: nothing in the launch depends on this paper.
- **Permanent publication of something later regretted.** Survivable up to step 7 by a revert;
  from the deposit onwards it is not, which is why the whole-PDF reading in step 6 and the
  disclosure check in step 7 come before it.

## What this plan does not do

- It does not change a word under `content/`. A8 and any teaching the paper turns out to need
  are their own wording pull requests.
- It does not edit the founding paper or the References page.
- It does not change the doctrine baseline, the caps, or any rule of an existing gate; it adds
  coverage.
- It does not add client-side script, a Pages Function or a build dependency to the site.
- It does not submit to a journal, create an account, or deposit anything.
- It does not create new agents or skills. If step 2 shows one is needed, it is named with the
  `upl-` prefix and recorded here first.

## Success criteria

1. **Every doctrinal statement in the published paper traces to a page under `content/` at the
   pinned commit**, and the traceability check passes in `bash scripts/check.sh`. If only one
   thing were true, this one would mean the paper complements the teachings and does not
   compete with them.
2. Every claim about a tradition, a figure, a book or science in the paper cites a register row
   that is live and not "secondary", and `python3 scripts/check-sources.py` passes with the
   paper source in scope.
3. The reference list is generated, not typed: deleting it and rebuilding reproduces it.
4. The balance report for the paper shows no tradition above the whole-text cap, and no
   section of the paper illustrating a belief through one tradition alone.
5. Every "resembles only" and "contrary" cell the paper draws on is worded as the cell's note
   says, and none is presented as agreement.
6. The content review of the `paper` type ends with no blocker and no major open.
7. The first page states that the author is the founder of what the paper describes.
8. The author approved every section by id, and the step 5 and step 6 pull requests say so.
9. `bash scripts/ci-local.sh` passes on the head commit of every pull request in the sequence,
   with its output in the merge commit body.
10. The published PDF is served by the site, passes the link check, and carries its permanent
    identifier once the deposit is made.

Negative criteria:

- `git diff` over the whole sequence shows no change to
  `paper/unified-path-of-light-synphotodosism.pdf`, to `scripts/doctrine-baseline.json`, or to
  the caps in `scripts/doctrine-gate.json`.
- No pull request in the sequence ran `scripts/check-doctrine.py` with `--accept-core` or
  `--waive-imbalance`.
- No statement about a tradition appears in the paper and nowhere in the register.
- No check reported as passed that could not run.

Rollback: steps 0 to 6 are each a single revert. Step 7 is a single revert up to the deploy.
From the deposit onwards the paper is public and permanently identified, and the only remedy is
a corrected version.

## Acceptance

A reader who finishes the founding paper and asks "where does this come from, and where does it
differ from what I already believe?" finds a second paper beside it that answers both, with a
source for every answer and the disagreements stated as plainly as the agreements. A scholar of
religion can cite it, check it, and see at once who wrote it and from what position. A Buddhist,
a Christian, a Hindu, a Jew, a Muslim, a Sikh or a follower of Seicho-No-Ie finds their
tradition described in its own words and not ranked. The founding paper is untouched, and the
teachings under `content/` remain the only place the teaching is made.
