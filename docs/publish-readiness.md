# Publish readiness

Where the Unified Path of Light stands on the way to being published, as of 21 September 2026. It
is written for the author, who was away while the last of this work was prepared and reviews each
pull request on return. The plans it draws on are
[launch readiness](plans/2026-09-18-launch-readiness.md) and
[page clarity](plans/2026-09-21-page-clarity.md).

## The short version

The text and the site are ready once the open pull requests are reviewed and merged. Nothing else
that can be done without the author is left. Going live then needs four things only the author
can do, listed under "What only the author can do".

## What is done

- **The teachings.** All 81 pages were read top to bottom and judged for clarity, alignment,
  logic and ease ([page-clarity-review.md](page-clarity-review.md)). Steps 1, 2, 3 and 6 of the
  plan are merged: every page has a description, every opening is a sentence, the physics is
  presented as analogy, and the long paragraphs are broken. Steps 4, 5 and 7 are applied in open
  pull requests.
- **Balance and sources.** No recorded imbalance, no tradition above 17 per cent of the whole
  text, the cross-reference matrix has no open finding, and every statement about another
  tradition, a figure, a book or science has a row in [sources.md](sources.md).
- **The site.** Static, no client-side JavaScript, every page passes the rendering gate at four
  widths, the contrast check, the link gate and the SEO gate. The contents cards now carry
  descriptions (open pull request).
- **Security and licensing.** Both audits of the launch plan were run and fixed; the secret scan,
  the dependency scan and the infrastructure scan pass; the licence is stated consistently.

## The combined release candidate

Every open pull request below was combined in a local branch and `bash scripts/ci-local.sh --all`
was run on the result: every job passed, including the rendering gate and the infrastructure
jobs. So the pull requests work together as well as one by one.

## The independent review

Four reviewers read that release candidate, each through one lens and without sight of the
others.

| Lens | Verdict | What it found |
| ---- | ------- | ------------- |
| Intellectual property | Pass | Quotations are public domain or short and attributed; the rest is paraphrase; images and fonts have recorded licences; indigenous teachings are credited to their peoples and no protected text is reproduced. One suggestion taken: say that the site mark and the social image are original work |
| Factual accuracy | Two majors, two minors | The Gospel does not say Jesus knelt to wash feet (stated twice); the God page framed "you are that" more strongly than its own source row allows; Guru Nanak did not "begin" the scripture; the Lord's Prayer ends before a doxology some manuscripts add. Everything else it checked was clean, including the physics, the medicine page and the Comparative Analysis |
| Consistency | Two majors, two minors | The Death page quotes the Gita's "for new ones", which implies the rebirth the author has left undefined; Other Spiritual Leaders says "beyond those named in this section" and names two who are; the figures' section page names four above a list of six; one "wellbeing" without its hyphen. Titles, headings, list entries, spellings, the five commitments and the retired words all checked clean |
| A newcomer's reading | No red flags; five majors | No cult markers at all: no money, no leader veneration, no exclusivity, no pressure, and the medicine page "about as safe as this genre gets". Strongest pages: the God page's "not as a claim of physics", the medicine page, the last paragraph of Karma, and Comparative Analysis. Weakest: Purpose, which is abstract where the rest is concrete; the home page, which is a table of contents and not a welcome; and nothing tells a convinced reader what to do next |

Each point was checked before it was acted on. Nine are fixed in the last pull request of the
stack as proposals P104 to P110 in [doctrine-decisions.md](doctrine-decisions.md). Left for the
author, because they are the author's words or facts only the author has:

- **Purpose** still reads as the most abstract page on the path a newcomer takes. Step 4 removes
  its ranking phrases; making it concrete would be a rewrite, and that is the author's.
- **Gatherings.** Two pages describe community without saying whether any gathering exists yet
  or how to find one. If the honest answer is "not yet", saying so would earn trust.
- **The author.** The Author Note gives faith and feeling and not who the author is.
- **The Lord's Prayer** ends before the doxology, as the author decided; a reader who opens the
  World English Bible will find one more sentence there.
- **Whether sobriety includes alcohol** (decision C4 of the page clarity plan).

## The open pull requests, in merge order

The content pull requests are stacked, each based on the one before, because they edit the same
records. Each shows only its own changes. As one merges, the next is retargeted to `main` and
rebased; the local CI is run on the rebased head before every merge.

| Order | Pull request | What | Baseline |
| ----: | ------------ | ---- | -------- |
| 1 | 54 | Step 4: the phrases that rank other religions; what Socinianism was | Purpose |
| 2 | 55 | Step 5: what Jesus, Muhammad, the Buddha and Taniguchi taught; two thin doctrine pages | six pages |
| 3 | 56 | Step 7: thirteen phrases polished, "follower", who may marry, the divorce page's title | five pages |
| 4 | 57 | Step 7: an example affirmation on each gratitude page | untouched |
| 5 | 59 | The fixes from the independent review, and this report | seven pages |
| any | 58 | Site: descriptions on the contents cards | untouched |

**About the baseline.** Pull requests 54 to 57 and 59 were prepared on the author's
instruction of 21 September 2026 to proceed "as if I had accepted all your suggestions" and to
review each one afterwards. Where a locked page changed, `--accept-core` was run under that
instruction, and each pull request says which fingerprints changed and that nothing else did.
`--waive-imbalance` was never needed. If a proposal is changed or dropped in review, the page and
the baseline are redone before the merge.

## What only the author can do

1. **Review and merge the pull requests above**, and answer decision C4.
2. **Make the repository public.** GitHub Actions has no budget left on the private repository, so
   neither CI nor the deploy workflow can start. Public repositories run Actions free of charge,
   which restores both, along with CodeQL and the branch ruleset the plan could not set on this
   plan. Every file has been treated as public from the first day, and the public-readiness gate
   passes. This step cannot be undone in any way that matters, so it is the author's alone.
3. **Create the Cloudflare credentials and run the first apply**, steps 1 to 7 of
   [runbook-go-live.md](runbook-go-live.md).
4. **Attach the domain**, step 8 of the runbook, for unifiedpathoflight.com.

Until step 2, the merge gate stays as decided on 21 September 2026: `bash scripts/ci-local.sh`
passing on the rebased head, with its output in the merge commit.
