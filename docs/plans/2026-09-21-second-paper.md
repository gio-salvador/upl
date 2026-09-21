# Write a second, sourced paper that places the Unified Path of Light among the traditions it draws on

**Status: planned, not built.** Requested 2026-09-21. This file records the design, the
sequence and the open decisions, so "not yet" stays a decision rather than becoming forgetting.
The author took decisions A1 to A8 the same day. Step 0 is under way; no later step has begun.
Nothing in it is wording for the paper: the paper's words are the author's.

**Amendments incorporated from review round 1, 21 September 2026.** Five lenses: accuracy,
process and locked decisions, completeness and sequencing, public surface, supersession. Two
blockers and five majors, all applied here:

- Only a PDF under `paper/` may reach the site; the working source must not (blocker; design
  "What the site serves", step 2, criterion 11).
- New literature is recorded as S rows only, and the bibliographic data file is checked field
  by field against its row, so no book is described in three places (blocker; "Sources and
  citations").
- The statements about traditions in "Where things stand" now cite their register ids (major).
- Step 7 is split in two, since the identifier exists only after the first half is live (major).
- The wording pull request for A8 has its own row in the Sequence (major).
- `site/scripts/check-seo.mjs` reads only the first scholarly article on the home page, and
  three repository documents describe `paper/` as holding one paper; both are now named in
  "Site" (two majors).
- Round 2, process and sequencing: the optional mentions under `content/` moved out of step 7a
  into their own wording pull request (row W2); "Open decisions" renamed; the edge from step 6
  to 7a stated.
- Round 2, supersession: the header rule for `/paper/*` and `docs/security.md` named, with no
  rule changed; the two link rewriters recorded as needing no change.
- Round 3: accuracy, process and sequencing, and supersession passed. The security-posture
  lens, newly applicable once the header rule was named, asked for a check on what is inside
  the built PDF, and for the identifier to be a plain link; both added ("Build",
  "Publication", step 6, Risks, criterion 14).
- Round 2, accuracy: the reference-list row recounted against the register (four corrected,
  one retired, not "three and one"), and two cells' ids completed.
- Minors applied: the contrary cells listed exactly, measurements given with their commands,
  machine state removed, paraphrase defined, one set of caps, step 5 as one pull request.

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

Measured on `main` at `4027fd2`. Word counts are approximate: `pdftotext` and `wc -w` on the PDF,
which includes the running heads, and `wc -w` over `content/**/*.md`, which includes front
matter. Shares come from `python3 scripts/check-doctrine.py --report`. Every statement about a
tradition in this table is a summary of a decision or a convergence-map cell, and cites the
register ids that cell rests on.

| | The founding paper | The teachings today |
| --- | --- | --- |
| Size | 24 pages, about 8,000 words | 81 pages under `content/`, about 13,000 words |
| Citations in the text | none; a list of 12 titles at the end | every statement about a tradition, a figure, a book or science rests on a row in [sources.md](../sources.md): 196 rows, S01 to S196 |
| How the traditions stand to each teaching | said in passing, mostly as agreement, and mostly through Islam in the ten core beliefs | the convergence map in [cross-reference.md](../cross-reference.md): over a hundred cells, each sourced, of which 17 are "resembles only" and 8 are "contrary" |
| Balance between traditions | Islam 40 per cent of mentions when first measured | no tradition above 17.4 per cent, by the doctrine report; the whole-text cap is 25 (`scripts/doctrine-gate.json`) |
| What God is | left open between a person and a principle | decided: impersonal, the source of light (D1) |
| Soul, consciousness, spirit, true image | used side by side, undefined | decided: one essence, several names (D4) |
| Where UPL parts from a tradition | one sentence, which described Buddhism as affirming suffering as inherent to life; decision D3 withdrew it | the eight "contrary" cells, stated openly: non-self (D3; S82, S124), a creator (S126 to S128), original sin (S131 to S134), eternal punishment (S38, S133, S134, S157 to S159), marriage in classical Christian, Islamic and Jewish teaching (S134, S140 to S143, S169, S176 to S178), and illness as unreal (D1, D2; S115). The resurrection of the body is a "resembles only" cell, not a contrary one (S144 to S146, S164, S165) |
| Healing | "cautious engagement" with medicine | decided: UPL heals the spirit, medicine treats the body, never spiritual remedies alone (D2) |
| Knowledge, the arts and technology | a way of life | decided: they serve spiritual evolution (D5) |
| How UPL addresses a follower | "expects", eight times, unclear | decided: four registers, belief, invitation, aspiration, commitment (D6) |
| The reference list | 12 entries, of which the catalogue check corrected four (R06, a word missing from the title; R08, listed under the wrong name, S01 and S02; R09, the work's spelling of its own name, S193; R10, a journal article and not a book, S192) and retired one as not a book at all (R04). The other seven stand as listed. All in the References table in [sources.md](../sources.md) | 24 entries, each checked against a catalogue |

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

## What is genuinely missing

1. **A content brief for the paper.** Surface, reader, voice, length, scaffold, disclosure
   surface, goal. The global rules ask for one before any content task.
2. **A source form and a build.** The founding paper exists only as a PDF. The second needs a
   text source under version control and a repeatable build to PDF, with the converter and the
   PDF engine named and their versions recorded (decision A6).
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
- A paraphrase written for the paper is new text that describes a teaching. It is not an edit
  to a teaching page and gives no licence for one. If the work on the paper shows that a page
  under `content/` should change, that is its own wording pull request, called out as locked
  decision 2 asks.
- Under `paper/`, the PDF is the published thing and the source is its working form. The
  architecture page gains one sentence saying so, so that a reader does not take the source for
  a second copy of the teachings.

### What the site serves (goal 3)

`site/scripts/sync-paper.mjs` copies the whole of `paper/` into the site's public folder. Left
as it is, the paper's source, the bibliographic data file and the traceability table would be
served from the day step 2 merges, unapproved drafts included. So step 2 changes the copy to
PDF files only, and adds a check, run from `bash scripts/check.sh`, that fails if anything
other than a PDF is found in the copied folder. It matters twice over, because the site lifts
its Content-Security-Policy for that path (see "Site"). The working files stay in the repository under
the licence that already covers `paper/**`, which is a decision to keep the work open to
inspection; they are not served as pages of the site.

### Sources and citations (goals 2, 4)

- In the source, a claim is cited by register id, as the teachings and the docs already do. The
  build turns ids into author and year in the text and a reference list at the end.
- The bibliographic fields live in a new data file keyed by register id (not a new register:
  [sources.md](../sources.md) stays the one place a source is recorded, and the gate checks
  that every key in the data file is a live row). Only the sources the paper cites need
  fields, which will be a fraction of the 196.
- One source, one description. New literature for the paper is recorded as S rows only, never
  as R rows: the R table mirrors the References page entry for entry, the source gate enforces
  that both ways, and References lists what the teachings cite, which this plan does not
  change. Where the paper cites a book that is already an R row, the data file is keyed to
  that row. The gate extension compares fields and not only keys: the title in the data file
  must be the title in the register row, and for an R row the author and title must be those
  of the References entry. The register wins any disagreement, and the data file is corrected.
- The paper's reference list is generated for the paper and is not a second References page.
  It lists what the paper cites; References lists what the teachings cite. They will differ,
  and the paper says so in its method section.
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
  the whole-text figure for `content/`, against the same caps. It reads the one `balance`
  object in `scripts/doctrine-gate.json` and not a copy, so a later change to a cap cannot
  reach the teachings and miss the paper. The new scan path in that file is a change to the
  gate's rules, so it is the author's to approve in step 2, as decision B8 was. The paper is
  not added to the teachings' count, which would move the author's baseline.
- A new small check holds the traceability table: every row's owner page exists at the pinned
  commit, and the pinned commit is an ancestor of `main`.
- All of these, and the served-files check above, run from `bash scripts/check.sh`, so `bash scripts/ci-local.sh` covers them.
- A `paper` content type joins `.claude/content-review.yaml` with the lenses scaffold,
  citation, domain-accuracy, ip, consistency (against the guardrails and against `content/`),
  audience-reader, titles and editor. The editor lens may fix typos and broken sentences only,
  as for a teaching. Its match is the paper source under `paper/`, which neither existing
  content type matches, so no file is reviewed twice or not at all.

### Build (goal 6)

Markdown source, a converter such as pandoc, one PDF committed under `paper/` like the first, in the same page
style so the two read as a pair. The build is a local script and is not part of the site
build, so the site stays static and the Cloudflare build gains no dependency. The PDF engine is
decision A6. The site needs no client-side script and no change to the Content-Security-Policy.

The PDF is a binary built on one machine, committed, and served from the one path where the
site lifts its policy, and after the deposit it cannot be withdrawn. So what is inside it is
checked before the freeze in step 6, by a script kept beside the build and with the result
written into the pull request:

- no JavaScript, no launch or submit action, no embedded file and no form in the PDF;
- every link in it is a plain address that also appears in the paper's source, and nothing is
  fetched from outside when it is opened;
- the document properties hold the title, the author's public name, the licence and the
  converter's name, and nothing else: no local path, no account name, no machine name;
- fonts are embedded, so the file reads the same everywhere, and each font's licence allows it;
- the build is repeatable: the same source and the same recorded versions give the same text
  and the same reference list, which is how a reader can trust that the PDF is the source.

The check is run by hand at the freeze, since it needs the build tools. So that a later change
to the PDF cannot skip it, the check records the SHA-256 of the file it passed, and
`bash scripts/check.sh` fails if the second paper's committed PDF does not match the recorded
value. The founding paper is outside this: it is kept as published.

### Site (goal 6)

A structural pull request, no teaching touched: the footer and the home page list both papers,
the structured data describes the second as a scholarly article by the same author, `llms.txt`
lists it, and the link, SEO and mobile checks cover the new link. The second paragraph of the
home page is already parked as the author's to write (S4 in the site review); the new link
waits for that wording or goes in the footer only.

The founding paper is kept on purpose, beside the second, and the author owns that decision
(goal 7). So every place that assumes one paper has to learn there are two, and none may be
left pointing at the first alone by accident:

- In the site: `site/src/lib/site.ts` (one `paperPath`), `site/src/lib/structured-data.ts` (one
  `paperSchema`), `site/src/layouts/Base.astro` (one footer link, one schema on the home page)
  and `site/src/pages/llms.txt.ts` (one entry).
- In the checks: `site/scripts/check-seo.mjs` finds the first scholarly article on the home
  page and tests that one alone. It is changed to test every one, or a broken second paper
  would pass.
- In the documents: `README.md`, `docs/architecture.md` and `docs/features-and-usage.md` each
  describe `paper/` as holding the founding paper. Each gains the second.
- In the headers: `site/public/_headers` lifts the Content-Security-Policy and the embedder
  policy for `/paper/*`, because browser PDF viewers need it, and `docs/security.md` records
  that the policy is lifted there only. The rule is a path prefix, so it already covers a
  second PDF and no rule changes: nothing is added, widened or loosened. Only the comment above
  the rule, which speaks of the founding paper alone, is brought up to date, and
  `docs/security.md` with it. This is also why "What the site serves" matters: anything served
  under that path is served without the policy, so it must be PDFs and nothing else.
- Needing no change, and checked: `site/src/lib/rewrite-links.mjs` and
  `site/src/lib/machine-text.ts` match links by the `../paper/` prefix and not by file name, so
  a page that links to the second paper resolves as it does for the first.
  `site/scripts/check-links.mjs` and `site/scripts/generate-og.mjs` have no logic for the paper.
- Under `content/`: `content/README.md` and `content/5-context/README.md` speak of "the
  founding paper" and "the paper's conclusion". Both stay true. Whether either should mention
  the second paper is wording on a rendered page, so it is not assumed and is not part of step
  7a. If the author wants it, it is row W2: proposals with ids through the `upl-teaching-steward`
  agent in improve mode, in a wording pull request of its own, as locked decision 2 asks.

A local checkout made by an agent session may exist under `.claude/worktrees/`. It is not
tracked and the gates do not descend into it; anyone verifying this plan by searching the tree
should exclude that path.

### Publication (goal 6)

The site first, then a public research archive that issues a permanent identifier and accepts
CC BY-SA 4.0, with the author's ORCID. The deposit is made by the author from the author's own
account: an agent does not create accounts or publish under the author's name. The identifier
then comes back into the repository in a citation file at the root and on the site, where it
and the ORCID are plain text links. No badge, icon or script is loaded from another origin,
which the site's policy would refuse in any case. The
archive's terms, its fit with the licence and how it handles versions are verified on its own
pages in step 7b, before anything is relied on.

### Who does what

| Work | Who |
| --- | --- |
| The decisions, the title, the abstract, the author note, the conclusion, approval of every section by id | the author |
| Finding and recording literature, never inventing a reference, marking what could not be opened | research agents, as in the tradition balance plan, step 1 |
| Section drafts as proposals, in a scratch tree, with the gates run before the author is asked | Claude, under the memory rule "gate drafts before approval" |
| Doctrine fidelity of each draft | the `upl-teaching-steward` agent, review mode |
| The review loop | the toolkit's content review with the `paper` content type |
| The disclosure check before anything leaves the machine | the NDA check, surface `public` |

## Decisions

All TAKEN by the author on 21 September 2026, in these words: "A1 companion, go with all your
recommendations". Each entry keeps the recommendation as the reasoning for the choice.

- **A1 TAKEN, as recommended: companion paper or second edition.** Recommendation: companion, as designed above.
  A second edition would restate what `content/` now says better than any PDF can, and would
  put two versions of the founding text in circulation.
- **A2 TAKEN, as recommended: the thesis.** Recommendation: the paper's centre is sections 4 and 5, that UPL can
  say precisely what it shares with each tradition and precisely where it parts, with sources,
  and that saying the second as plainly as the first is what separates a synthesis from a
  blend. The alternative centre is section 3, a doctrinal development paper; it is the easier
  paper and the less useful one to a reader outside UPL.
- **A3 TAKEN, as recommended: voice.** Recommendation: scholarly first person. "I" for the author's decisions and
  position, plain description for the traditions, the author's own recorded words quoted where
  a decision is reported. Not the devotional voice of the founding paper, which a reader of
  this paper can find in the founding paper.
- **A4 TAKEN, as recommended: where it is published.** Recommendation: the site and one open research archive
  with a permanent identifier, deposited by the author. Costs nothing and keeps the licence.
- **A5 TAKEN, as recommended: a peer-reviewed journal afterwards.** Recommendation: decide after publication,
  not before. So this one is taken as a deferral: the question is still open, on purpose, until the paper is out. Three things to weigh then, each to be verified and not assumed: many journals
  ask for a licence other than CC BY-SA or for first publication; open-access journals often
  charge a fee; and a founder writing on the founder's own religion is an insider account,
  which some journals welcome as such and others do not take.
- **A6 TAKEN, as recommended: the PDF engine.** Recommendation: install one small engine locally (Typst or
  Tectonic, each a single binary) and record the version in the build script. The alternative,
  pandoc to a word processor file and export by hand, matches how the first paper was probably
  made and is not repeatable.
- **A7 TAKEN, as recommended: when.** The repository is private and the site is not yet live
  ([launch readiness](2026-09-18-launch-readiness.md)). Recommendation: write now, publish only
  after the site is public, so the paper's links to the teachings resolve on the day it appears.
- **A8 TAKEN, as recommended: W3 first.** The two accuracy points on the doctrine pages, the hard problem of
  consciousness called "empirically-based" and the observer effect, are the author's to settle
  and are still parked. Recommendation: settle them as a wording pull request before step 5
  drafts section 6. Otherwise the paper either repeats a statement the site review has marked
  inaccurate, or says something the teachings do not.

## Sequence

One pull request per row. Each leaves `main` green under `bash scripts/ci-local.sh`.

| Step | Pull request | Needs from you | Status |
| --- | --- | --- | --- |
| 0 | This plan, reviewed with the plan review | read it; A1 to A8 | decisions taken 2026-09-21; plan review passed on all six lenses after three rounds; waiting for `bash scripts/ci-local.sh` and the merge |
| 1 | The brief: the content brief written from decisions A1 to A8, the scaffold fixed | approve the brief | not started |
| 2 | Scaffolding: the paper source tree with headings only, the build, the bibliographic data file, the copy narrowed to PDFs with its check, the three gate extensions, the `paper` content type, the sentence in the architecture page | the engine install (A6); approve the new scan path in the doctrine gate's rules | not started |
| 3 | Literature: register rows (S rows only) for sections 6, 7 and 8, and primary sources in place of any secondary row the paper will cite | nothing, unless a source has to be bought | not started |
| 4 | The annotated outline and the traceability table: for each section, the claims it will make, the owner page and the sources, no prose | approve the outline by section | not started |
| W | Outside this plan's own work, and tracked here because step 5 waits on it: the wording pull request that settles the two W3 accuracy points under `content/` (A8), through the teaching steward | approve the wording by id | not started |
| 5 | Drafts: one pull request, with three approval batches inside it as checkpoints, each a set of proposals with ids: sections 2 to 5; sections 6 to 8, which wait for row W; sections 0, 1 and 9, which are the author's own | approve, change or decline by id | not started |
| 6 | Review loop to a bounded cap, quotations checked by eye, the freeze: commit pinned, PDF built, its contents checked (see "Build") and committed, version 1.0 | read the PDF whole, once | not started |
| 7a | Site wiring and the documents that name one paper, nothing under `content/`; the disclosure check; merge and deploy, so the paper has a live address | the home page wording, or footer only | not started |
| W2 | Optional, and outside this plan's own work like row W: whether `content/README.md` and `content/5-context/README.md` mention the second paper, as its own wording pull request through the teaching steward, after 7a | say whether it is wanted; approve the wording by id | not started |
| 7b | After the author's deposit: the archive's terms verified, the identifier and the citation file into the repository and onto the site | the deposit; the ORCID | not started |

Step 3 can run beside step 2, and row W beside both. Steps 4 and 5 cannot start before step 3 ends for the sections
that need new sources, and can start at once for sections 2 to 5.

## Cross-dependencies

| Edge | Why it is hard and not tidy |
| --- | --- |
| Step 1 before everything | A1 changes what is being written; A3 changes every sentence |
| Sources before wording (step 3 before 4 and 5) | The source gate refuses a claim without a row, and the rule is that the row comes first. A draft written ahead of its sources gets bent to fit them |
| Row W (A8, the W3 points) before the second batch of step 5 | Goal 3: the paper cannot say about science what the teachings do not yet say |
| Inside step 2: the data file before the gate extension | The gate checks the data file's keys against the register; it cannot pass on an absent file |
| Inside step 5: the steward's review before the author is asked | The author should not spend an approval on a draft that contradicts a core belief |
| Inside step 6: the pin after the last wording pull request to `content/` | A pin taken earlier reports a text that has since moved |
| Step 6 (the PDF committed) before step 7a | The link check and the SEO check in 7a need a real, committed PDF to test |
| The launch plan before step 7a | The paper links to the teachings by URL; A7 |
| Step 2's narrowed copy before any working file lands under `paper/` on `main` | Otherwise the site serves working files on the next deploy |
| Inside step 7a: the disclosure check before the deploy | The deploy is the first moment the paper is public |
| Step 7a before the deposit, and the deposit before step 7b | The deposit needs a live address to point to; the identifier does not exist until the deposit is made. A deposit with a permanent identifier cannot be taken back |

## Risks

- **The paper drifts into a second source of doctrine.** Survivable because of the pin, the
  traceability table and its gate, and the rule that a new statement goes to `content/` first.
- **A tradition is misdescribed in a permanent, citable document.** Worse than on a page, which
  can be corrected in a pull request. Survivable because every such claim carries a row with
  its caution, the domain-accuracy lens checks it live, the quotations are checked by eye, and
  the archive chosen in A4 has to allow a corrected version under the same identifier family;
  that is one of the things step 7b verifies, before the deposit is relied on.
- **An invented or half-remembered reference.** The failure that would cost the paper its
  standing. Survivable because research agents are told never to invent and to mark what they
  could not open, and the reference list is generated from rows a gate has checked, not typed.
- **The scholarly section turns into a defence of UPL, or ranks traditions.** Survivable
  because section 8 is in the scaffold from the start, the consistency lens treats ranking as a
  major, and the paper's balance is counted.
- **Something unwanted inside the PDF.** Active content, or a local path or account name in the
  document properties, in a file served without the site's policy and then deposited for good.
  Survivable because the contents check in "Build" runs before the freeze and its result is
  in the pull request, and because the file is built from a text source anyone can rebuild.
- **Quotation beyond what copyright allows.** Survivable: the ip lens, short quotations, open
  translations preferred.
- **Borrowing from living peoples.** The Hawaiian and indigenous material is the most exposed
  to the charge of appropriation. The paper says what the sources allow and no more, and
  section 8 names the question instead of avoiding it. This is a risk accepted in part: the
  paper cannot settle it, only state it honestly.
- **The author's time.** Step 5 is the largest reading task since the core beliefs were
  rewritten. Three batches, each reviewable in one sitting, is the mitigation. There is no
  deadline, which is a decision: nothing in the launch depends on this paper.
- **Permanent publication of something later regretted.** Survivable up to and including step 7a by a revert;
  from the deposit onwards it is not, which is why the whole-PDF reading in step 6 and the
  disclosure check in step 7a come before it.

## What this plan does not do

- It does not change a word under `content/`. A8 (row W), the two optional mentions (row W2) and
  any teaching the paper turns out to need are their own wording pull requests, tracked in the
  Sequence only so that what waits on them is visible.
- It does not edit the founding paper or the References page.
- It does not change the doctrine baseline, the caps, or any rule of an existing gate; it adds
  coverage.
- It does not add client-side script, a Pages Function or a build dependency to the site, and
  it changes no header rule: in `site/public/_headers` only a comment is updated.
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
11. The built site serves nothing from `paper/` but PDF files, and the check that holds this
    fails when a markdown file is placed there as a test.
12. No book is described differently in two places: the field comparison between the
    bibliographic data file and the register passes, and `python3 scripts/check-sources.py`
    still reports the register and References in step.
13. The SEO check tests every scholarly article on the home page: breaking the second paper's
    address in a scratch build makes it fail.
14. The contents check on the frozen PDF reports no active content, no outside fetch and no
    document property beyond title, author, licence and converter, and its output is in the
    step 6 pull request.

Negative criteria:

- `git diff` over the whole sequence shows no change to
  `paper/unified-path-of-light-synphotodosism.pdf`, to `scripts/doctrine-baseline.json`, or to
  the caps in `scripts/doctrine-gate.json`.
- No pull request in the sequence ran `scripts/check-doctrine.py` with `--accept-core` or
  `--waive-imbalance`.
- No statement about a tradition appears in the paper and nowhere in the register.
- No check reported as passed that could not run.

Rollback: steps 0 to 6 and row W are each a single revert. Step 7a is a single revert, before or
after the deploy, though once deployed a copy may already have been fetched or cached, so the
reading in step 6 is the real safeguard.
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
