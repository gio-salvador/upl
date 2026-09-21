# Doctrine guardrails

What a new or changed page under `content/` has to stay true to, how the traditions the
teachings draw on are kept in balance, and what stops a page that fails either from being
published. For anyone writing or reviewing a teaching, and for any agent working in this
repository.

This page is not a teaching. It is an index for writers and reviewers, in my words and not the
words of the founding paper. Where it and a page under `content/` disagree, the page under
`content/` is right and this page needs fixing.

## 1. The beliefs a page must not contradict

Each line names a belief, the page that states it, and what a deviation looks like. A page does
not have to mention any of them. It must not work against them.

| Belief | Stated in | A page deviates when it |
| --- | --- | --- |
| All existence is one, a manifestation of divine light. God is that light, not a being in human form. | [Unity](../content/1-foundations/core-beliefs/unity.md), [God, Quantum Physics, and the Light of Divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | describes God as a person with human traits, or divides people or things into those inside the light and those outside it |
| Science and spirituality complement each other. Quantum physics is offered as an analogy. | [God, Quantum Physics, and the Light of Divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | sets faith against science, or claims that physics proves a doctrine |
| The soul is immortal and the body is its temporary cocoon. | [The Immortal Soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | treats a person as only matter, or treats the body as worthless |
| Karma is the law of moral cause and effect. Dharma is the path of right action and duty. | [Karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md), [Dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md) | replaces them with reward and punishment handed down by a judging God |
| Death is a transition and consciousness continues. | [Death as a Transformative Journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md) | teaches an end of the soul, or eternal punishment |
| Enlightened figures from many traditions embody the same light. None is ranked above another. | [The Role of Enlightened Figures](../content/2-doctrine/enlightened-figures/README.md), [Respect for the Wisdom of World Traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md) | calls one figure, scripture or religion the truest, the final or the only one |
| Holy texts are read as symbol and teaching, not as literal truth. Truth runs through all of them. | [Engaging with Holy Texts](../content/3-practice/holy-texts.md) | requires a literal reading, or calls a text free of error |
| Ethics is a personal, growing practice, not a rigid code. | [Ethical and Moral Development](../content/2-doctrine/ethical-and-moral-development/README.md) | lays down rules with penalties, or condemns people rather than actions |
| Compassion is owed to all beings. | [Compassionate Action](../content/1-foundations/core-beliefs/compassionate-action.md) | excuses contempt for any group, believer or not |
| Family takes many forms and none is lesser. Marriage is encouraged, not required. Divorce is accepted as a last resort. | [Family](../content/4-way-of-life/family/README.md) | ranks family forms, or makes marriage a duty |
| Sobriety, care of the body, and trust in science and evidence-based medicine. | [Holistic Well-being](../content/4-way-of-life/holistic-wellbeing/README.md) | endorses recreational drugs, or advises against medical treatment |
| Care for the Earth is a spiritual duty. | [Environmental Stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | treats nature as only a resource |
| Practice is free and plural: prayer, meditation and texts from any tradition. | [Practices and Rituals](../content/3-practice/README.md) | makes one form of practice compulsory, or forbids another tradition's practice |
| Freedom of conscience. Nobody is pressed to believe. | [Purpose](../content/1-foundations/purpose.md) | threatens, shames or pressures the reader into belief |
| Positive thinking, gratefulness and mindful action. | [Positive Thinking, Gratefulness, and Mindful Action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md) | teaches through fear or guilt |

The ten principles in [Core Beliefs and Principles](../content/1-foundations/core-beliefs/README.md)
are the fixed centre. A new page extends or applies them. A page that adds an eleventh
principle, removes one or redefines one is a change to the religion itself, and only the author
makes it.

## 2. Balance between the traditions

The teachings draw on Christianity, Islam, Buddhism, Hinduism, Judaism and Seicho-no-Ie, and name others
such as Taoism, Sikhism, the Hawaiian practice of Ho'oponopono and indigenous spiritualities.
They stand side by side. None is the lens through which the others are read.

Rules for every new or changed page:

1. **No default tradition.** When a page illustrates a belief through a tradition, it
   illustrates it through at least two, or through none. A belief that stands on its own needs
   no parallel at all.
2. **Spread the parallels.** Across a section, draw on the whole range the teachings name. Do
   not reach for the same tradition page after page, whichever one it is.
3. **Order is not rank.** When several traditions are listed, vary which comes first from page
   to page.
4. **A tradition's own terms, used correctly.** Tawhid, the Eightfold Path, agape, dharma,
   Shinsokan: use a term as its tradition uses it, and do not claim two terms mean the same
   thing when they only resemble each other.
5. **Shared teachings are written as shared.** Where several traditions hold a teaching, the
   page says so once, and credits the origin first where one tradition took it from another.
   A sentence naming several traditions needs a source for each. The convergence map in
   [cross-reference.md](cross-reference.md) records how each tradition stands to each teaching.
6. **Dedicated pages are the exception.** A page whose subject is one figure or one practice,
   such as the page on the Buddha or on Shinsokan meditation, names that tradition alone. These
   pages are listed under `dedicated` in `scripts/doctrine-gate.json`.

### Where the text stands today

The ten core belief pages were first written with Islam as the only parallel: Islam carries
every mention of a tradition in that section, and about 40 per cent across the whole text
against a cap of 35. That is a known imbalance, not the intent. It is recorded in
`scripts/doctrine-baseline.json` so the gate can hold the line on everything new while those
pages wait for the author. Rewording them is a change to the wording of a teaching, so it
happens only when the author asks for it, in its own pull request
([CLAUDE.md](../CLAUDE.md), locked decision 2).

## 3. The gate

`scripts/check-doctrine.py` runs as part of `bash scripts/check.sh`, so it runs before every
push through the local hook and in CI on every pull request. It fails on:

- **Contrary language.** Wording that contradicts a belief outright: a claim of exclusive
  truth, a ranking of traditions, a slur for outsiders, scriptural literalism, eternal
  punishment, advice against medicine, forced belief. The patterns are under `contrary` in
  `scripts/doctrine-gate.json`.
- **A page out of balance.** A page that names one tradition and no other, or where one
  tradition carries more than 60 per cent of five or more mentions.
- **A section or the whole text out of balance.** One tradition above 50 per cent of a
  section, or above 25 per cent of the whole text (35 until 21 September 2026, when the text had come into balance and the author lowered it). A recorded imbalance may shrink. It may
  never grow.
- **A changed page that is still out of balance.** An existing imbalance is recorded against
  the exact text of the page. Edit the page and the record no longer applies, so the page has
  to come into balance in the same change.
- **An undeclared change to a core page.** Every page under `content/1-foundations/` and
  `content/2-doctrine/` is recorded by fingerprint. Changing, adding, removing or renaming one
  fails until the author records it.

See what the gate counts on each page:

```bash
python3 scripts/check-doctrine.py --report
```

### The author's two decisions

```bash
python3 scripts/check-doctrine.py --accept-core
python3 scripts/check-doctrine.py --waive-imbalance
```

The first records the current core pages after a change the author made or approved. The second
records the imbalances that exist now, and is also how a cleared one is removed. Both rewrite
`scripts/doctrine-baseline.json`, which shows up in the pull request for the author to review
as code owner. Nobody else runs them, and an agent never runs them to make the gate pass.

### What the gate cannot do

It counts words and matches patterns. It will not notice a page that contradicts a belief in
polite language, a parallel that misdescribes a tradition, or a balance that is there in number
and absent in spirit. That is what review is for.

## 4. Review

- `upl-teaching-steward` ([agents/upl-teaching-steward.md](agents/upl-teaching-steward.md))
  reviews a page against these beliefs, proposes improvements for the author to approve, and
  drafts new pages. It judges what the gate cannot count.
- `sc-content-review` reads this page as the reference for its `consistency` lens on every
  teaching (`.claude/content-review.yaml`), and runs the gate as a machine check first.
- `sc-plan-review` holds any plan that touches `content/` to these rules through its
  `process-locked` lens (`.claude/plan-review.yaml`).
- The author is code owner of `content/` and of the gate's rules and baseline, and reviews
  every change to them.
- The pull request template asks for the balance and the beliefs to be confirmed.

## 5. Writing a new page

1. Find the belief the page extends in the table above, and read the page that states it.
2. Write the page. If it needs a parallel from a tradition, use at least two, chosen from
   traditions the section has not leaned on already.
3. Run `python3 scripts/check-doctrine.py --report` and read the counts for the page and its
   section.
4. If the page says anything about another tradition, a figure, a book or science, record the
   source first (section 6).
5. Run `bash scripts/check.sh`, then open the pull request.

## 6. Sources

A teaching is believed, not proved, and needs no source. A statement about the world does: what
another tradition teaches, what a figure said, what a book contains, what science has found.
Such a statement is only as good as its source, and a religion that honours other traditions
owes them accuracy.

Rules for every new or changed page, under `content/` and under `docs/`:

1. **Record before you rely.** A statement about another tradition, a named figure, a book or
   science goes in only with a row in the [source register](sources.md) that supports it.
2. **Cite by id.** Pages point at a source by its id, such as S07. The link itself lives in the
   register and nowhere else, so it is corrected in one place.
3. **Primary before secondary.** The scripture, the paper, the publisher, the tradition's own
   body. An encyclopaedia is for orientation, and is replaced before the statement reaches a
   teaching.
4. **Quote exactly or not at all.** Never invent a quotation, a scripture reference or a
   historical detail. If it cannot be checked, it is marked to verify and left out of the page.
5. **Credit what is borrowed.** An image, a phrase or a passage taken from another tradition is
   credited on the page that uses it.
6. **The bibliography and the register move together.** A change to
   [References](../content/5-context/references.md) is recorded in the register in the same
   pull request.

`scripts/check-sources.py`, run by `scripts/check.sh`, holds the mechanical part: complete rows,
no outside link on a claim-bearing page that is not in the register, no cited id that does not
exist, no recorded source that nothing cites, and References and the register entry for entry.
It cannot tell whether a source is good or says what the row claims. That is for the `citation`
and `domain-accuracy` lenses of the content review, and for the author.
