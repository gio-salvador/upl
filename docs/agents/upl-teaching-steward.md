# upl-teaching-steward

Reviews the teachings under `content/` against the ten core principles and the beliefs in
[doctrine-guardrails.md](../doctrine-guardrails.md), proposes exact wording improvements for the
author to approve, and drafts new pages that extend the core beliefs in the voice of the
founding paper. For the author, and for anyone helping the author with the text. The source is
`.claude/agents/upl-teaching-steward.md`.

## Modes

| Mode | What it does | Does it edit? |
| ---- | ------------ | ------------- |
| `review` (default) | Judges a page, a section or the whole text for fidelity to the beliefs, balance between the traditions, accuracy about other traditions and science, coherence, completeness and clarity. | No |
| `improve` | Reviews, then turns findings into numbered proposals, each with the exact text before and after, the belief it serves and its effect on the gate. | Only proposals the author approved, exactly as written |
| `create` | Drafts a new page from a brief, places it in the right section, lists it in the folder's `README.md`, runs the gates and reviews its own draft. | Yes, new files and the section list |

## Use it

Ask Claude Code in this repository, in plain words:

- "Use upl-teaching-steward to review `content/4-way-of-life/family/`."
- "Use upl-teaching-steward to improve `content/3-practice/prayer.md`." Read the proposals,
  then: "Apply P1 and P4."
- "Use upl-teaching-steward to draft a page on forgiveness under practice."

## What it will not do

- Reword a teaching without the author's approval of that exact change.
- Add, remove or redefine one of the ten core principles.
- Run `scripts/check-doctrine.py` with `--accept-core` or `--waive-imbalance`, edit
  `scripts/doctrine-baseline.json`, or loosen `scripts/doctrine-gate.json`. When approved work
  lands on a locked core page, it leaves that one gate failure for the author to record.
- Lean on one tradition, rank traditions, or state something about another tradition it is not
  sure of. Unsure statements come back marked `[VERIFY]`.
- Write for search engines or language models.
- Commit, push or open a pull request. Wording changes and structural changes are reported
  apart so they can go in separate pull requests.

## How it fits with the other checks

The doctrine gate counts words and matches patterns. `sc-content-review` runs the fleet's
generic reviewer lenses over a page before it ships. This agent sits before both: it is the one
that knows the beliefs, works with the author on what a page should say, and hands over a draft
that the gate and the review then hold to account.
