# Publish readiness

Where the Unified Path of Light stands on the way to being published, as of 21 September 2026. It
is written for the author, who was away while the last of this work was prepared and reviews each
pull request on return. The plans it draws on are
[launch readiness](plans/2026-09-18-launch-readiness.md) and
[page clarity](plans/2026-09-21-page-clarity.md).

## The short version

The text and the site are ready. Going live needs three things only the author can do, listed
under "What only the author can do".

## What is done

- **The teachings.** All 81 pages were read top to bottom and judged for clarity, alignment,
  logic and ease ([page-clarity-review.md](page-clarity-review.md)). Steps 1, 2, 3 and 6 of the
  plan are merged: every page has a description, every opening is a sentence, the physics is
  presented as analogy, and the long paragraphs are broken. Steps 4, 5 and 7 are merged too.
- **Balance and sources.** No recorded imbalance, no tradition above 17 per cent of the whole
  text, the cross-reference matrix has no open finding, and every statement about another
  tradition, a figure, a book or science has a row in [sources.md](sources.md).
- **The site.** Static, no client-side JavaScript, every page passes the rendering gate at four
  widths, the contrast check, the link gate and the SEO gate. The contents cards now carry
  descriptions.
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

Each point was checked before it was acted on. Nine are fixed as proposals P104 to P110 in [doctrine-decisions.md](doctrine-decisions.md). Left for the
author, because they are the author's words or facts only the author has:

- **Purpose** still reads as the most abstract page on the path a newcomer takes. Step 4 removes
  its ranking phrases; making it concrete would be a rewrite, and that is the author's.
- **Gatherings.** Two pages describe community without saying whether any gathering exists yet
  or how to find one. If the honest answer is "not yet", saying so would earn trust.
- **The author.** The Author Note gives faith and feeling and not who the author is.
- **The Lord's Prayer** ends before the doxology, as the author decided; a reader who opens the
  World English Bible will find one more sentence there.
- **Whether sobriety includes alcohol** (decision C4 of the page clarity plan).

## The pull requests

On 21 September 2026 the author accepted everything prepared in their absence ("accept and merge
all"). Pull requests 54, 55, 56, 57, 59 and 58 were merged in that order, each rebased on `main`
with the local CI passing on the rebased head. Where a locked page changed, `--accept-core` had
been run under the author's earlier instruction, which the acceptance confirms; every pull
request records which fingerprints changed and that nothing else did. `--waive-imbalance` was
never needed.

## What only the author can do

1. **Make the repository public.** GitHub Actions has no budget left on the private repository, so
   neither CI nor the deploy workflow can start. Public repositories run Actions free of charge,
   which restores both, along with CodeQL and the branch ruleset the plan could not set on this
   plan. Every file has been treated as public from the first day, and the public-readiness gate
   passes. This step cannot be undone in any way that matters, so it is the author's alone.
2. **Create the Cloudflare credentials and run the first apply**, steps 1 to 7 of
   [runbook-go-live.md](runbook-go-live.md).
3. **Attach the domain**, step 8 of the runbook, for unifiedpathoflight.com.

Until step 1, the merge gate stays as decided on 21 September 2026: `bash scripts/ci-local.sh`
passing on the rebased head, with its output in the merge commit.
