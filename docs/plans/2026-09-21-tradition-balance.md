# Bring the traditions into balance across the whole text

**Status: decisions taken, not started.** Requested 2026-09-21. The author took decisions B1 to
B7 the same day; no step has begun. It records the
measurements, the design, the decisions that are the author's, and the sequence, so the work can
be done a page at a time without losing the whole picture.

## What was asked for

In the author's words, on 2026-09-21, after seeing the distribution of mentions between the
religions: "do a more detailed plan to improve balance across the board".

It follows from locked decision 8 in `CLAUDE.md` ("The traditions are kept in balance. No
tradition is the default lens… The early text leans on Islam more than was intended") and from
the adoption options discussed on 18 to 21 September 2026, in which the author reviewed what
could be drawn from Christianity, Seicho-No-Ie, Judaism, Buddhism and Hinduism. The three
decisions those options depended on are taken and recorded in
[doctrine-decisions.md](../doctrine-decisions.md) as D1 to D4.

## Where the text stands

Measured on `main` at `e469db4` with `python3 scripts/check-doctrine.py --report`. The gate
counts each time a tradition is named, by its name, figures, scriptures or own terms. The seven
pages dedicated to one figure or practice are left out of the shares. Karma and dharma are not
counted, because the teachings have adopted them as their own.

| Tradition | Mentions | Share | Pages naming it |
| --- | ---: | ---: | ---: |
| Islam | 29 | 33% | 19 |
| Buddhism | 17 | 19% | 9 |
| Seicho-no-Ie | 14 | 16% | 8 |
| Christianity | 11 | 12% | 9 |
| Hinduism | 8 | 9% | 5 |
| Hawaiian tradition | 4 | 4% | 3 |
| Taoism | 2 | 2% | 1 |
| Judaism | 2 | 2% | 2 |
| Sikhism | 1 | 1% | 1 |
| Indigenous traditions | 1 | 1% | 1 |

| Part | Mentions | Distribution |
| --- | ---: | --- |
| Foundations | 22 | Islam 86%, Christianity 5%, Buddhism 5%, Seicho-no-Ie 5% |
| Doctrine | 31 | Buddhism 23%, Seicho-no-Ie 19%, Hinduism 19%, Islam 16%, Christianity 13%, Taoism 6%, Sikhism 3% |
| Practice | 6 | Hawaiian 50%, Seicho-no-Ie 33%, Buddhism 17% |
| Way of Life | 10 | Christianity 30%, Buddhism 20%, five others at 10% |
| Context | 20 | Buddhism 30%, Islam 20%, Seicho-no-Ie 20%, Christianity 15%, Hinduism 10%, Judaism 5% |

What the numbers say:

1. **The imbalance is one section.** The ten core beliefs and their index name Islam and nothing
   else: 19 of Islam's 29 mentions. Outside Foundations, Islam is about 15 per cent of the text.
   Twelve of the thirteen recorded imbalances, and the only section-level one, are there.
2. **Practice names almost no tradition** outside its three dedicated pages: six mentions, none
   from Christianity, Islam, Hinduism or Judaism. The pages on prayer and on holy texts name no
   tradition at all, although both are about drawing on many.
3. **Hinduism is under-credited.** Karma and dharma come from it, and it is named on five pages.
4. **Judaism, Taoism, Sikhism and the indigenous traditions are close to absent.** The one page
   that leans on indigenous spiritualities names none of them.
5. **Four of Seicho-no-Ie's fourteen mentions are entries in the References list**, so its real
   presence in the teaching is lower than the count.

## Goals

1. **No tradition is the default lens anywhere.** Serves locked decision 8. Measured per page,
   per section, per part and for the whole text.
2. **The five traditions the teachings build on stand in the same range.** Christianity, Islam,
   Buddhism, Hinduism and Seicho-no-Ie each hold between 12 and 25 per cent of the whole text.
   Balance here means a range, not equal quotas.
3. **The traditions the teachings name but barely use have a real voice.** Judaism, Taoism,
   Sikhism, the Hawaiian tradition and the indigenous traditions together hold at least 15 per
   cent, and each is named on at least three pages.
4. **Every recorded imbalance is gone.** Thirteen today, none at the end, each removed because
   the page came into balance and never because it was waived again.
5. **Every voice is a real teaching, correctly stated and sourced.** A tradition is named for
   something it actually teaches, in its own terms, with a row in the
   [source register](../sources.md). This is the goal that keeps goal 1 honest.
6. **The balance holds afterwards.** The gate is tightened to the new level so the text cannot
   drift back, and that tightening is the author's decision.

Non-goals:

- **No quotas and no padding.** A tradition named in passing to move a number is a defect, not
  progress. If a belief has no true parallel in a tradition, that tradition is not named there.
- **Islam is not removed.** Its voice stays wherever it is accurate. It becomes one voice among
  several, of equal length with the others (decision B2).
- **No new principle and no redefined principle.** The ten core beliefs keep their meaning.
  Voices illustrate a belief; they do not change it (locked decision 7).
- **No wording written for search engines or language models** (locked decision 3).
- **No adoption of another tradition's practices** beyond what a page already promises. Whether
  UPL takes up, say, a weekly day of rest is a separate decision from balance.

## What already exists, and must not be rebuilt

| Need | Already present |
| --- | --- |
| Counting, caps and the ratchet on recorded imbalances | `scripts/check-doctrine.py`, `scripts/doctrine-gate.json`, `scripts/doctrine-baseline.json` |
| The balance rules: two traditions or none, spread the parallels, vary the order, own terms used correctly, dedicated pages | [doctrine-guardrails.md](../doctrine-guardrails.md), section 2 |
| The decisions the adoption work depended on | [doctrine-decisions.md](../doctrine-decisions.md), D1 to D4 |
| One owner page per concept, recorded overlaps | `scripts/content-index.json`, [cross-reference.md](../cross-reference.md) |
| Sources recorded before they are relied on, and the gate that holds it | [sources.md](../sources.md), `scripts/check-sources.py`, guardrails section 6 |
| The way a wording change is made: exact before-and-after proposals the author approves by id | `.claude/agents/upl-teaching-steward.md`, improve mode |
| Review lenses for accuracy, citation and respect | `.claude/content-review.yaml` |

## What is genuinely missing

1. Voices from other traditions on the ten core beliefs.
2. Named traditions on the practice pages that are about many traditions.
3. Credit to Hinduism where karma, dharma and the soul are taught.
4. Named indigenous traditions on the page that leans on them, and a fuller Historical Context.
5. Primary sources in the register for every teaching to be named.
6. A title for belief 4 that names no single tradition (decision B3), and dedicated pages for
   Laozi and Guru Nanak (decision B4).
7. Tighter caps once the text is in balance.

## The design

### The rule for a voice (goal 5)

A voice is one to three sentences that (a) state a teaching the tradition really holds, (b) use
the tradition's own term for it, (c) say how it meets the belief of the page, without claiming
the two are the same, and (d) rest on a source already in the register. Each page gets at least
two voices that it does not have today, or none. Across a section the first-named tradition
rotates. A voice is never added to a page only because the page needs a number.

### The assignment for the ten core beliefs (goals 1, 2, 4)

Under decision B2 each of the ten pages is rewritten as one balanced passage: the belief stated
first, in UPL's own words and keeping the author's sentence wherever the page already has one,
then three or four voices of equal length, Islam among them. The "Keeps" column is the Islamic
teaching that stays as one of those voices. The teachings named here were reviewed with the
author on 18 to 21 September 2026; the wording is still to be written and approved. "First" is
the tradition named first on the page, so the order rotates.

Several of these pages today describe Islam more than they state the belief (beliefs 3 and 6
most of all), and six open with a fragment carried over from the founding paper (W1 in
[site-review.md](../site-review.md)). A rewrite is the moment to give each page a first sentence
that states the belief. That sentence is doctrine, so it is the author's above all: the draft
offers one, and the author writes the final one.

| # | Belief | Keeps | Gains | First |
| --- | --- | --- | --- | --- |
| 1 | Unity | Tawhid | Hinduism: the self and the ultimate reality are one. Christianity: "you are the light of the world" | Hinduism |
| 2 | Spiritual Evolution and Practice | prayer, fasting, pilgrimage | Hinduism: the four paths, for different temperaments. Buddhism: the path of practice | Buddhism |
| 3 | Ethical and Moral Living | justice, Ummah, Zakat | Judaism: tzedakah, giving as justice. Hinduism: ahimsa, non-violence. Christianity: turn the other cheek, the peacemakers | Judaism |
| 4 | Inclusive Family Structures and Innate Goodness (renamed, decision B3) | Fitrah, now named in the body | Seicho-no-Ie: the person as child of God, already perfect. Buddhism: Buddha-nature. Judaism and Christianity: made in the image of God | Seicho-no-Ie |
| 5 | Compassionate Action | helping those in need | Judaism: love your neighbour, and Hillel's rule. Christianity: love of enemies, the Good Samaritan. Buddhism: the four immeasurables | Christianity |
| 6 | Interconnectedness and the Pursuit of Knowledge | Ilm | Buddhism: dependent origination, which also gives the text its missing definition of interconnectedness (finding X07). Judaism: study and honest disagreement | Buddhism |
| 7 | Respect for the Wisdom of World Traditions | respect for the prophets | Hinduism: "truth is one; the wise call it by many names". Seicho-no-Ie: all religions come from one source | Hinduism |
| 8 | Environmental Stewardship | creation as a trust | Judaism: do not destroy or waste. Indigenous traditions, named. Christianity: Francis of Assisi | Indigenous |
| 9 | Community and Social Welfare | Ummah | Buddhism: the Sangha. Christianity: "the least of these". Sikhism: the shared meal and service | Sikhism |
| 10 | Positive Thinking, Gratefulness, and Mindful Action | gratitude and right conduct | Seicho-no-Ie: the power of words. Christianity: do not be anxious. Buddhism: the mind goes before all things | Seicho-no-Ie |

The rewrite replaces the sentences that held the two wording slips in beliefs 4 and 7, approved
on 18 September 2026, so those slips close with it.

**Renaming belief 4 (decision B3).** The title becomes "Inclusive Family Structures and Innate
Goodness", because innate goodness is what Fitrah, Buddha-nature, the image of God and the child
of God each point at. The file becomes `inclusive-family-structures-and-innate-goodness.md` and
its web address changes with it; the site is not public yet, so no address in use breaks. The
rename touches the core beliefs index, `scripts/content-index.json`, the generated
`docs/cross-reference.md` and `scripts/doctrine-baseline.json`, and it changes the name of a core
principle without changing its meaning, which locked decision 7 reserves to the author and the
author has decided. With "Fitrah" out of the title, the index page names no tradition and its
recorded imbalance clears with no change to the gate.

### The other parts (goals 1, 3)

| Part | Page | What is missing | Voices to draft |
| --- | --- | --- | --- |
| Practice | Adopting Prayers from Various Traditions | names no prayer | one short prayer each from three traditions, read as attunement (D1): the Lord's Prayer, "lead me from darkness to light", a loving-kindness verse |
| Practice | Engaging with Holy Texts | names no text | Buddhism: test a teaching by its fruits; the raft. Christianity: the allegorical reading of Origen and Augustine. Hinduism: the Upanishads as teaching by dialogue |
| Practice | Incorporating Various Forms of Meditation | no introduction | an introduction naming the three forms and Christian contemplative prayer |
| Practice | the four gratitude pages, Mindful Action | name none | Seicho-no-Ie: gratitude to parents and ancestors. Judaism: the ethics of speech. Buddhism: right speech and right intention |
| Doctrine | Karma | names none | Hinduism: acting without attachment to the fruit. Judaism: return and repair after a wrong. And the safeguard that karma is never a verdict on a person who suffers |
| Doctrine | Dharma | names none, and the concept is Hindu | Hinduism: one's own dharma. Buddhism: the Dhamma as the teaching |
| Doctrine | Other Spiritual Leaders | two figures share one page | decision B4: a dedicated page each for Laozi and for Guru Nanak, listed under `dedicated` in the gate's rules; the shared page stays as a short pointer to figures still to come |
| Way of Life | Environmental Stewardship (section page) | leans on "indigenous spiritualities" and names none: the thirteenth recorded imbalance | named indigenous traditions, with Judaism and Seicho-no-Ie |
| Way of Life | Sobriety | cites no tradition | Buddhism: the fifth precept. Sikhism: abstaining from intoxicants |
| Way of Life | the Family section | cites none | Seicho-no-Ie: gratitude to parents. Hinduism: the stages of life. Judaism: peace in the home |
| Way of Life | Professional Development, Service and Philanthropy | cite none | Buddhism: right livelihood. Hinduism: the four aims of life. Sikhism and Hinduism: seva |
| Context | Historical Context | names Islam, pantheism and Socinianism only | Buddhism, Hinduism and Seicho-no-Ie, which the text builds on throughout |
| Context | Comparative Analysis | Hinduism appears only as the caste system | one fair sentence on what UPL shares with Hinduism beyond karma and dharma |

### What the numbers become

A projection, not a promise: about two mentions per new voice, from the two tables above.

| Tradition | Now | After the core beliefs | After every part |
| --- | ---: | ---: | ---: |
| Islam | 33% | about 21% | about 17% |
| Buddhism | 19% | about 20% | about 20% |
| Christianity | 12% | about 16% | about 17% |
| Seicho-no-Ie | 16% | about 15% | about 15% |
| Hinduism | 9% | about 12% | about 14% |
| Judaism | 2% | about 7% | about 8% |
| Sikhism, Taoism, Hawaiian, Indigenous | 8% | about 9% | about 9% |

The core beliefs step alone meets goals 1 and 2 for the whole text and clears twelve recorded
imbalances. The other parts are what meet goal 3 and bring Practice out of near-silence.

### Sources first (goal 5)

Before any voice is drafted, its source goes into the register. Primary sources are preferred:
the scripture itself in a public-domain or openly licensed translation, or the tradition's own
body. Quotations from the Bible use a public-domain translation. The list to record: Leviticus
19:18 and Hillel (Shabbat 31a); Matthew 5 to 7, 22 and 25, Luke 10 and 15; the Chandogya and
Brihadaranyaka Upanishads, the Bhagavad Gita, Rig Veda 1.164.46; the Dhammapada, the Kalama
Sutta, the raft simile, the five precepts, the four immeasurables, dependent origination;
Taniguchi's Truth of Life and the Nectarean Shower; Maimonides on giving; the Guru Granth Sahib
on service; and a named source for each indigenous tradition cited. Each becomes a row, and the
References page gains the books the teachings then rely on. The chapter and verse numbers in
this list are from memory and are not yet checked; confirming each one is what step 1 is for.

### Keeping it (goal 6)

When the text is in balance the caps are moved to where the text then is, so it cannot drift
back: the whole-text cap from 35 to 30 per cent, the section cap from 50 to 40. A new report
line shows how many traditions each part names and which tradition each page names first, so
rotation can be seen. Changing `scripts/doctrine-gate.json` changes what may be published, so it
is the author's decision (B5) and is made last.

## Decisions

All taken by the author on 21 September 2026.

- **B1 TAKEN: ranges.** No tradition above 25 per cent; Christianity, Islam, Buddhism, Hinduism
  and Seicho-no-Ie each between 12 and 25; the other five together at least 15, each named on
  three pages or more.
- **B2 TAKEN: rewrite each page.** Each core belief is redrafted as one balanced passage, the
  belief first and then three or four voices of equal length. This was not the recommendation,
  which was to keep every sentence and add to it. It gives the best reading result and changes
  the most of the author's original words, so every page comes back to the author as a whole
  before-and-after, and the founding paper in `paper/` remains the record of what was first
  written.
- **B3 TAKEN: rename belief 4** to "Inclusive Family Structures and Innate Goodness". This was
  not the recommendation, which was a change to how the gate counts. The rename leaves the gate
  alone and fixes the cause: a core belief whose name belongs to one tradition.
- **B4 TAKEN: a page each** for Laozi and for Guru Nanak.
- **B5 TAKEN: decide the tighter caps at the end**, from the real numbers. Today's proposal is 30
  per cent for the whole text and 40 for a section.
- **B6 TAKEN: Judaism is a named source tradition.** It joins the list in section 2 of the
  guardrails, and its books join References.
- **B7 TAKEN: one batch of proposals per step**, approved, changed or declined by id.

## Sequence

One pull request per step. Each leaves `main` green. Every step that touches `content/` is a
wording pull request, called out as such, with the matrix and the register updated in it.

| Step | Pull request | Needs from you | Status |
| --- | --- | --- | --- |
| 1 | Sources: the primary sources for every voice in this plan recorded in the register; Judaism added to the guardrails' list of traditions (B6); References proposals drafted | approve the References additions by id | not started |
| 2 | Core beliefs 1, 4, 5, 7 rewritten, and belief 4 renamed (B3). Clears five records: the four pages and the index | approve each page by id; `--accept-core`; `--waive-imbalance` to remove the cleared records | not started |
| 3 | Core beliefs 2, 3, 6, 8, 9, 10 rewritten. Clears six page records and the section record | the same | not started |
| 4 | Practice: prayer, holy texts, the meditation introduction, gratitude and mindful action | approve by id | not started |
| 5 | Doctrine and Way of Life: karma, dharma, the pages for Laozi and Guru Nanak (B4), environmental stewardship, sobriety, family, work and service | approve by id; `--accept-core` for the doctrine pages; `--waive-imbalance` for the thirteenth record | not started |
| 6 | Context: Historical Context and Comparative Analysis. Then the tighter caps and the new report lines (B5) | approve by id; the caps | not started |

Steps 2 and 3 can be drafted together and merged in either order. Steps 4 and 5 do not depend on
each other. Step 6 is last because the caps are set from the numbers the earlier steps produce.

## Cross-dependencies

- **Sources before wording.** Step 1 comes before every other step; the source gate refuses a
  new References entry without a register row, and guardrails section 6 asks for the row before
  the statement.
- **One owner per concept.** About thirty concepts arrive with these voices (dependent
  origination, tzedakah, ahimsa, the four immeasurables, Buddha-nature, the image of God, seva
  and others). Each gets one owner page in `scripts/content-index.json` in the step that first
  states it, and later pages link to the owner and do not restate it.
- **Decisions D1 to D4 bind every draft.** Prayers that address God are read as attunement (D1);
  any teaching on healing is a complement to medicine (D2); Buddhism's teaching on the self is
  not adopted (D3); soul, spirit, consciousness and true self are one essence (D4).
- **The baseline.** Every step that touches Foundations or Doctrine needs the author's
  `--accept-core`, and every step that clears a recorded imbalance needs the author's
  `--waive-imbalance` to remove the stale record. An agent runs either only on the author's
  explicit instruction for that change, and verifies what it rewrote.
- **The rename.** Belief 4's new file name has to change in the index page, the matrix and the
  baseline in the same pull request, or three gates fail at once.
- **The three Foundations slips.** Beliefs 4 and 7 close in step 2. The Author Note slip
  ("tranquillity") is independent and can go at any time with `--accept-core`.

## Risks

- **Tokenism.** The easiest way to move the numbers is to name traditions without saying
  anything. Guard: the rule for a voice, the steward's review lens for "a second tradition named
  only in passing to satisfy the number", and the author's approval of each passage.
- **Christianity becomes the new default.** It fits many of the ten beliefs well, and the
  assignment uses it on six. Guard: it is first-named on one page only, and the projection keeps
  it under 20 per cent.
- **Misdescribing a tradition.** Every voice is a statement about the world. Guard: primary
  sources in step 1, the citation and domain-accuracy lenses, and terms used as the tradition
  uses them. Resemblance is never presented as identity.
- **Borrowing what is not ours to take.** Kabbalah, yoga and indigenous practice are often
  appropriated. Guard: describe and credit, do not absorb; name indigenous traditions
  specifically and from their own sources, or not at all.
- **The core beliefs lose the author's voice.** Under B2 these ten pages, the centre of the
  religion, are rewritten, and a draft by anyone but the author will sound like the drafter.
  Guard: the belief's own sentence is the author's to write; the author's existing words are
  kept wherever they state the belief; each page comes back whole for the author to rework, not
  only to approve; and the voices are held to one to three sentences each so a page of forty
  words does not become an essay.
- **A belief quietly changes meaning.** A strong voice can pull a belief towards its own
  tradition. Guard: locked decision 7, and the review lens for fidelity to the beliefs.
- **The author's time.** About forty proposals. Guard: batches by step, and steps that can pause
  between pull requests without leaving the text worse than it was.

## What this plan does not do

- It does not add, remove or redefine a core belief.
- It does not decide whether UPL adopts any tradition's practices.
- It does not fix the sentence fragments (W1) or the accuracy points (W3) recorded in
  [site-review.md](../site-review.md) outside the ten core beliefs, where the rewrite (B2)
  replaces them.
- It does not write front-matter descriptions (S5 in the site review), though steps 2 and 3 are
  a natural moment for the author to add them, since those pages are being recorded anyway.
- It does not loosen any gate.

## Success criteria

Each is checked with `python3 scripts/check-doctrine.py --report` on `main`, unless it says
otherwise.

1. No tradition holds more than 25 per cent of the whole text.
2. Christianity, Islam, Buddhism, Hinduism and Seicho-no-Ie each hold between 12 and 25 per cent.
3. Judaism, Taoism, Sikhism, the Hawaiian tradition and the indigenous traditions together hold
   at least 15 per cent, and each is named on at least three pages.
4. No part with ten or more mentions has a tradition above 40 per cent, and every part names at
   least five traditions.
5. The report shows no known imbalance: `scripts/doctrine-baseline.json` has empty `pages`,
   `sections` and `corpus`.
6. Across the ten core beliefs, no tradition is named first on more than two pages.
7. Every tradition named on a changed page is supported by a row in `docs/sources.md` whose kind
   is not "secondary", and `python3 scripts/check-sources.py` passes.
8. `python3 scripts/check-content-index.py` passes with every new concept owned by one page and
   no new open finding of type `conflicting`.
9. The caps in `scripts/doctrine-gate.json` are at or below 30 per cent for the whole text and 40
   for a section, and `bash scripts/check.sh` passes.
10. No pull request in the sequence changes a sentence the author did not approve by id, and
    each rewritten core belief still states the same belief, by the author's own judgement.
11. The core beliefs index names no tradition, and belief 4's title names none.

## Acceptance

A reader who opens any of the ten core beliefs meets the belief first and then hears it echoed by
several traditions, none of them louder than the rest. A Buddhist, a Christian, a Hindu, a Jew, a
Muslim or a follower of Seicho-No-Ie finds their tradition described in its own words, accurately,
with its source, and finds that it is neither the measure of the others nor measured by them. The
gate keeps it so.
