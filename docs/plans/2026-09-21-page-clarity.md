# Make every page clear, consistent and easy to follow

**Status: in progress.** Step 1 is done, 21 September 2026. The review behind it is
[page-clarity-review.md](../page-clarity-review.md); the description drafts are
[page-descriptions.md](../page-descriptions.md).

## What was asked for

In the author's words, on 2026-09-21: "draft the page descriptions, and also read each individual
page and assess for clarity, if they are well aligned with core beliefs, logic, and ease of
understanding, each page, top to bottom, create a plan for fixing them, keep them short and sweet."

## Where the text stands

All 81 pages were read in full. 48 are good as they stand. 33 need a fix, and most fixes are one
sentence. Seven things recur: openings without a subject, physics claimed where decision D1 says
it is not, two phrases that rank other religions, six thin pages, four walls of text, five names
for a follower, and four affirmation pages with no affirmation. No page has a description.

## Goals

1. **Every page has a description** of its own, so search results, link previews and contents
   cards say what the page says.
2. **Every page opens with a complete sentence** and can be read on its own.
3. **No page contradicts the author's decisions** D1 to D6, or itself.
4. **No page ranks another religion.**
5. **No page is a stub, and none is a wall.**
6. **Pages stay short.** A fix may not make a page longer than it needs to be: the target is under
   250 words for a leaf page, with the God page, belief 6, Comparative Analysis and the medicine
   page as the known exceptions.

## The design

The working rule is the one already in use: draft, apply in a scratch tree, run the doctrine,
matrix and source gates, revert, write each proposal into `docs/doctrine-decisions.md` with a
P-id, and apply only what the author approves, word for word. One pull request per step. Steps 2
to 5 and 7 are wording changes and say so. `--accept-core` is run only on the author's instruction
and the baseline is compared before and after.

Each fix is the smallest that works. A fragment gets its missing words, not a new sentence. A
contradiction is settled by the decision already taken, not by new doctrine.

## Decisions

The author's, before the step that needs each.

| Id | Question | Needed by |
| -- | -------- | --------- |
| C1 | Approve, or edit, the 81 descriptions. **Decided 21 September 2026: all approved.** | Step 1 |
| C2 | The God page: keep quantum physics as analogy only, and drop "literal" and the observer-effect sentence? Recommended: yes, it is what D1 already says. | Step 3 |
| C3 | One name for a follower. Recommended: "follower", already the most used, with "Synphotodosist" kept where the name itself is the point. | Step 7 |
| C4 | Does sobriety include alcohol? | Step 7 |
| C5 | Who may marry: any two adults? | Step 7 |
| C6 | A new title for the divorce page. Recommended: "Divorce as a Last Resort". | Step 7 |
| C7 | The affirmations themselves: the author's words, which a draft can prompt and cannot replace. | Step 7 |
| C8 | The Fabric of Ethics: fold it into the section introduction, or give it a second paragraph? | Step 5 |

## Sequence

| Step | What | Pages | Kind | Status |
| ---- | ---- | ----: | ---- | ------ |
| 1 | Descriptions into front matter (S5 in the site review). Showing them on the contents cards (S6) is a site change and goes in its own pull request | 81 | Metadata | Done |
| 2 | Give each fragment its subject and verb | 8 | Wording | - |
| 3 | Bring the God page, Abstract, Continuum page and Conclusion into line with D1, D2 and D5 | 4 | Wording | - |
| 4 | Remove the ranking phrases from Purpose and Comparative Analysis; gloss Socinianism | 3 | Wording | - |
| 5 | Give Jesus, Muhammad, the Buddha and Taniguchi what Laozi and Guru Nanak have; settle the liberation page and the Fabric of Ethics | 6 | Wording | - |
| 6 | Break the long paragraphs, set the four lost headings in bold, fix one ʻokina. No word changes. Proposals P69 to P73; the reordering of belief 6 was withdrawn when checked | 5 | Structure | Drafted |
| 7 | Small polish on 12 good pages, and the author's own words: follower naming, alcohol, marriage, the divorce title, the affirmations, the home page | 20 | Wording | - |

Step 6 touches locked pages, so it too needs `--accept-core`, although no word changes.
Steps 1 and 6 can go first and together; 2 to 5 in any order; 7 last, because C3 touches many pages.

## Risks

- **Polish becomes rewriting.** Held by the smallest-repair rule and by proposals the author reads
  one at a time.
- **Expanding the four figures upsets the balance.** Dedicated pages are outside the shares, and
  every draft goes through the doctrine gate before it is shown.
- **New statements about figures need sources.** Most are already in `docs/sources.md`; any new one
  gets a row first.

## What this plan does not do

It does not add doctrine, settle the open question of what follows death, or change the site's
design. It does not replace the independent content review before the site goes public.

## Success criteria

1. All 81 pages have a unique description of 50 to 200 characters, and `check-seo` passes.
2. No page or section under `content/` opens with a sentence that lacks a subject or a verb.
3. No page says or implies that the teaching about light is a claim of physics.
4. No connecting text ranks a tradition or calls another's view outdated or "mere".
5. No leaf page is under 80 words; no paragraph is over 150.
6. One name for a follower throughout, apart from the exceptions the author allows.
7. Every row marked "Fix" in the review is closed or has a recorded reason to stay.
8. `bash scripts/ci-local.sh` passes on every step, and the matrix keeps no open finding.
