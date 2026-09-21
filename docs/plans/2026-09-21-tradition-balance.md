# Bring the traditions into balance across the whole text

**Status: done, 21 September 2026.** All seven steps are merged. No recorded imbalance remains, from
fourteen; no tradition holds more than 17 per cent of the whole text, from Islam at 40; and the
whole-text cap is 25 per cent, from 35. What is left is in "Parked items" below and is not part
of this plan's goals. Requested 2026-09-21. The author took decisions B1 to
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

Two further rules come from the convergence map. A sentence that names several traditions
together needs a source for each one it names, so "Judaism, Christianity and Islam all teach…"
cannot be written to score three mentions with one unsourced claim. And a teaching one tradition
took from another names the origin first: Jesus's "love your neighbour" is credited to
Leviticus, which he is quoting.

### The convergence map (goals 1, 5)

The author asked on 21 September 2026 how the plan accounts for beliefs shared between more than
one religion. It did not. The gate counts names and the assignment lists voices side by side,
and both treat the traditions as separate columns. For a religion whose premise is that many
traditions see one light, the intersections are the strongest evidence it has, and a page that
lists "one says, another says" hides them.

The map records, for each teaching, how each tradition stands to it: **origin**, **inherits**
(naming from where), **holds independently**, **resembles only**, or **contrary**. Every cell
carries source ids. It lives in the cross-reference matrix, as `held_by` on each concept in
`scripts/content-index.json`, and is rendered in [cross-reference.md](../cross-reference.md).
`scripts/check-content-index.py` holds it: a cell needs a known tradition, a relation and a
source that exists in the register; an inherited teaching names an origin that holds it; a
resemblance or a contrary teaching says how it differs; and every tradition a page names has to
be accounted for in the concepts that page owns. On its first run that last check found that
belief 10 credits Islam with positive conduct and mindful awareness, for which no source is
recorded.

As built: 87 cells on 25 teachings, the ten beliefs among them. What it shows:

- **Six beliefs are held by five or six traditions each**: spiritual practice, ethical living,
  compassion, environmental stewardship, unity and interconnectedness. These are the real common
  ground, and their pages lead with what is held in common.
- **Compassion is one teaching with a lineage.** Judaism is its origin, Christianity inherits it,
  and four other traditions hold it independently.
- **Respect for world traditions and positive thinking are held by only two.** Most of what looks
  like agreement there is resemblance: the Rig Veda verse and the Buddha's raft for the first, the
  Dhammapada and "do not be anxious" for the second. Those pages say less about other traditions
  than the assignment proposed, and say it more carefully.
- **Buddhism resembles more than it shares** on four teachings and stands contrary on the soul.
  It meets UPL in practice, ethics and compassion, not in doctrine. That is a truer account of
  the relation than its 19 per cent of mentions.
- **Three contrary cells are recorded**, all already decided: Buddhism on the self (D3),
  Seicho-No-Ie on the reality of illness (D1, D2), and the Christian passage that ends in eternal
  punishment.

How it shapes a rewritten belief: the belief first, in the author's words; then one sentence on
what several traditions hold in common, with the lineage where there is one; then one or two
voices that are distinctive and not repetitive; and, where it matters, an honest line on who
sees it differently, pointing to Comparative Analysis.

The map also gives a second measure of balance beside the count of mentions: how many teachings
each tradition truly shares in, resembles or stands against. It is reported in the rendered view.

Cells left out because no source is recorded yet, to be sourced before the page that needs them:
Western Christianity's original sin against innate goodness; the exclusive claims within
several traditions against respect for all; the classical teaching of most traditions on
marriage against inclusive family structures; Christianity and Islam on the immortal soul;
Buddhism and Taoism on a creator; the image of God in a Christian source; gratitude in Judaism
and Christianity; Taoism throughout, which has its sources (S111, S112) and no cell yet.

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

### What the source check changed (step 1)

Step 1 opened a primary source for every teaching named above and recorded 110 of them in the
[source register](../sources.md), S14 to S123. Every reference given from memory held, with one
number corrected. What did not hold was how several teachings are popularly worded. The voices
are drafted from the register and carry its cautions. The changes to the assignment:

| # | Voice | What the source says | What changes |
| --- | --- | --- | --- |
| 1 | Islam: Tawhid | The Light Verse, "God is the Light of the heavens and the earth" (S101), is a closer parallel to UPL's central image than the oneness surah (S88) | Offer the Light Verse as the Islamic voice on Unity, beside or in place of Tawhid |
| 1 | Hinduism: "you are that" | The word Brahman is not in the verse; identity is one school's reading of three (S64) | Keep the wording already on the God page, which takes no side; do not strengthen it |
| 1 | Christianity: the light of the world | Three different sayings with three different subjects: the disciples (S32), Jesus of himself (S42), God (S44) | Use "you are the light of the world" and do not merge it with the others |
| 2 | Hinduism: the four paths | The Gita names action, knowledge and devotion, never as a set (S56, S57); the fourfold scheme is from the 1890s and is weakly sourced (S58) | The voice says "paths of action, knowledge and devotion, for different temperaments" |
| 3 | Judaism: tzedakah | It means both righteousness and charity (S18, S19) | Never "justice, not charity" |
| 3 | Hinduism: ahimsa | "Non-violence is the highest duty" is said in a discussion of eating meat, in an epic that endorses righteous war (S62); Patanjali's non-injury is the Yoga school's (S59, S61) | Name it as a virtue, not as pacifism, and say whose |
| 3 | Christianity: the other cheek | "The second mile" is a paraphrase; the longer form of "love your enemies" is doubtful (S32) | Quote the World English Bible as it stands, or paraphrase without quotation marks (S31) |
| 4 | Islam: Fitrah | The Qur'anic verse (S89) is the clean citation; the hadith goes on to say parents make the child a Jew, a Christian or a Magian (S90) | Cite the verse, not the hadith, on a page that honours those traditions |
| 4 | Buddhism: Buddha-nature | A Mahayana teaching, contested within Mahayana, sourced so far to an encyclopaedia and one Theravada critic (S83, S84) | Needs one more neutral source before it is written; the safe wording is "Mahayana traditions teach that all beings have the potential for awakening" |
| 4 | Judaism and Christianity: the image of God | The verse does not say what the image is (S22) | State the verse; leave the meaning open |
| 5 | Judaism: love your neighbour | In context the neighbour is a fellow Israelite; the wider reach is the verse on the stranger (S14, S15, S16). Hillel's rule ends "go and study" (S17) | Cite both verses together, and quote Hillel whole. Jesus is quoting the Torah (S37), so the credit runs to Judaism first |
| 5 | Christianity: love of enemies, the Samaritan | The word "good" is not in the parable, which is in Luke alone (S40); "love your enemies" in its short form (S32) | Tell the parable for what it shows: the neighbour is whoever shows mercy, across every boundary |
| 5 | Buddhism: the four immeasurables | In their source they lead to a heavenly rebirth, not awakening, and the name is later (S72, S73) | Name them as love, compassion, rejoicing and equanimity, without claiming more |
| 6 | Buddhism: dependent origination | In every early text it explains how suffering arises and ceases (S74). The reading as the interconnection of all things is the Huayan school's and Thich Nhat Hanh's (S75, S76) | The voice credits Huayan's net of Indra and interbeing for interconnectedness, and does not put it in the Buddha's mouth. This is the correction that matters most: the plan had proposed it as the text's definition |
| 6 | Islam: Ilm | The well-known hadith has a very weak chain (S94); "My Lord, increase me in knowledge" is sound (S95) | Anchor Ilm in the verse |
| 6 | Judaism: study and disagreement | Confirmed (S23, S24) | None |
| 7 | Hinduism: "truth is one" | The verse says "To what is One, sages give many a title" and names Vedic gods; "truth" is not in it, and the reading as a statement about religions is modern (S51) | Say what the verse says, and credit the modern reading as modern. Seicho-No-Ie's "all religions emanate from one universal God" (S113) is the nearer match to UPL's premise and leads the page |
| 8 | Islam: stewardship | The translations say "successors"; stewardship is a common modern reading (S96, S97) | "Often understood as stewardship" |
| 8 | Judaism: do not destroy | A rabbinic extension of a verse about fruit trees in a siege; the environmental reading is modern (S20, S21) | "Derives from", and say the application is modern |
| 8 | Indigenous traditions | Three can be named from their own bodies: Māori kaitiakitanga (S119), the Haudenosaunee Thanksgiving Address (S120), Hawaiian aloha ʻāina and mālama ʻāina (S121). Ecuador's constitution is a legal fact only (S123). The Lakota phrase is not used at all | Name these three, each as that people's own responsibility and not as a general ethic |
| 8 | Christianity: Francis | "Patron of those who promote ecology", 29 November 1979 (S46); the Canticle, about 1225 (S47) | Use the exact title |
| 8 | Seicho-No-Ie | "Grand Harmony of God, Nature, and Human Beings" (S117) | Use the movement's own formula |
| 9 | Buddhism: the Sangha | In the early texts, the monastic order or the community of the awakened; the wider use is modern (S86, S78) | Say so. Community and Fellowship already uses the word loosely and inherits the caution |
| 9 | Sikhism: the shared meal and service | Traditionally traced to Guru Nanak, with Sufi precedents (S105, S108); service and equality are in the scripture itself (S109, S110, S106, S107) | "Traditionally"; and Sikhism, not Hinduism, is the sourced home of seva |
| 9 | Christianity: the least of these | "The least of these my brothers", in a passage that ends in eternal punishment (S38) | Quote verse 40 only, knowingly |
| 10 | Buddhism: the mind goes first | The verse is about mind or intention leading speech and action. It does not say thoughts create reality (S68) | Keep it distinct from Seicho-No-Ie's law of the mind (S113), which does say that. Two voices that resemble each other and are not the same |
| 10 | Christianity: do not be anxious | The passage turns on "seek first God's Kingdom" (S33) | Do not present it as a promise of provision |

Findings for the later steps, recorded so they are not lost:

- **Prayer.** The Lord's Prayer ends before the doxology in the critical text (S33). "Lead me from
  darkness to light" differs by translator (S52). Al-Fatiha is recited in every unit of the
  prayer (S102).
- **Holy texts.** The Kalamas are told to reject bare reasoning as well as tradition (S79, S80);
  the raft is set down only after the crossing (S81); allegory was one strand of early Christian
  reading, and Augustine warns against it as well as for it (S48, S49, S50).
- **Karma and dharma.** Acting without attachment to the fruit (S53). One's own dharma is bound to
  caste in the text itself (S54, S55, S63, S67), so the Dharma page credits the Gita and says what
  UPL does not take. Return and repair after a wrong (S25). The Buddhist sense of the word is
  different (S87).
- **Way of life.** The fifth precept (S77, S78) and the Sikh code (S107) on intoxicants; right speech
  and livelihood (S70, S71) and the ethics of speech (S26); the stages and aims of life (S63);
  peace in the home, which is mainly about marriage (S27); the day of rest (S28); gratitude to
  ancestors (S116); forgiveness (S36, S41) and not judging, where the first-stone story is a later
  insertion and still canonical (S34, S42, S45); service (S39, S43); giving in secret (S33).
- **Ho'oponopono.** The traditional practice is a family process led by a respected mediator; the
  four-phrase version is a modern adaptation (S122). The Ho'oponopono Meditation page calls it a
  "technique", which describes the adaptation. A finding for step 5, and the word should carry
  its ʻokina.
- **Shinsokan.** What the practice involves is now sourced (S115), for the page that does not say.
- **Buddhist meditation.** Mindfulness of breathing is sixteen steps on a path to liberation, not a
  relaxation method (S85); the familiar loving-kindness method is from a later commentary (S73).
- **Figures.** Laozi may be legendary (S111, S112); Guru Nanak's dates are uncertain (S103, S104).
  The Taniguchi page should not read as endorsing his politics (S118), and the Grand Harmony
  message is not to be quoted in English until the movement's own translation has been seen
  (S114).
- **Already on `main`.** "Buddhism teaches that there is no permanent self" in Comparative Analysis
  is inside what the source supports (S82, S69). Healing with a word is confirmed as written
  (S35). "The world is one family" is a late text about a detached sage (S65); Diwali is kept by
  several traditions (S66); tikkun olam in its social sense dates from the 1950s (S29, S30); the
  yamas and niyamas are Patanjali's (S59, S60); zakat, the five pillars, community, gratitude and
  mercy are sourced (S91, S92, S93, S98, S99, S100).

### References additions (approved and applied)

The References page lists twelve books and none of the scriptures the teachings quote. Proposed
new entries, each already in the register. The author approved Q1 to Q13 on 21 September 2026 and
they were applied as written, with R14 to R25 recorded in the register. For Q11 the new entry
stands beside the doubtful one (R04), which the author may now remove.

- **Q1.** The Hebrew Bible, in the translation of the Jewish Publication Society (S14)
- **Q2.** The Babylonian Talmud, tractate Shabbat (S17)
- **Q3.** "Mishneh Torah" by Moses Maimonides (S18)
- **Q4.** The World English Bible, a public-domain translation of the Bible (S31)
- **Q5.** The Qur'an, in the translation of M. A. S. Abdel Haleem (S93)
- **Q6.** The Upanishads (S64, S52)
- **Q7.** The Bhagavad Gita (S53)
- **Q8.** The Dhammapada and the discourses of the Pali Canon, in the translations of Bhikkhu
  Sujato (S68)
- **Q9.** The Guru Granth Sahib, in the translation of Sant Singh Khalsa (S103)
- **Q10.** "Tao Te Ching", attributed to Laozi, in the translation of James Legge (S111)
- **Q11.** "Truth of Life" (Seimei no Jissō) by Masaharu Taniguchi, to stand beside or replace the
  doubtful entry "Seicho-No-Ie" (R04)
- **Q12.** "Nānā i ke Kumu" by Mary Kawena Pukui, E. W. Haertig and Catherine A. Lee (S122)
- **Q13.** Correct the entry for the Socinianism volume to its editors (R08)

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
this list were from memory when the plan was written; step 1 has since checked each one.

### Keeping it (goal 6)

When the text is in balance the caps are moved to where the text then is, so it cannot drift
back: the whole-text cap from 35 to 30 per cent, the section cap from 50 to 40. A new report
line shows how many traditions each part names and which tradition each page names first, so
rotation can be seen. Changing `scripts/doctrine-gate.json` changes what may be published, so it
is the author's decision (B5) and is made last, in step 7.

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
- **B5 TAKEN: decide the tighter caps at the end**, from the real numbers. Decided on 21 September
  2026: 25 per cent for the whole text, measured against a highest share of 17.4; the section cap
  stays at 50, because 40 would fail the soul section (Hinduism, for karma and dharma) and
  Environmental Stewardship (indigenous voices), which are rightly where they are.
- **B6 TAKEN: Judaism is a named source tradition.** It joins the list in section 2 of the
  guardrails, and its books join References.
- **B7 TAKEN: one batch of proposals per step**, approved, changed or declined by id.
- **B8 TAKEN, 21 September 2026: add the words, in step 3.** The words the gate counts. The gate recognises a tradition by a list of words in
  `scripts/doctrine-gate.json`. The new voices use words it does not know: Hillel, Maimonides,
  tzedakah and Leviticus for Judaism; Samaritan for Christianity; Upanishad is known but Rig Veda
  only as "Veda"; sutta, metta and Huayan for Buddhism; langar and Guru Granth Sahib for Sikhism;
  Māori, Haudenosaunee and ʻāina for the indigenous and Hawaiian traditions. Without them the
  gate under-counts exactly the traditions this plan adds, and the reported shares will be wrong.
  Recommendation: add them in step 3, in the same pull request as the first voices. It makes the
  count more accurate and does not loosen anything, but it changes the gate's rules, so it is the
  author's to approve.

## Sequence

One pull request per step, except that steps 1 and 2 share one. Each leaves `main` green. Every step that touches `content/` is a
wording pull request, called out as such, with the matrix and the register updated in it.

| Step | Pull request | Needs from you | Status |
| --- | --- | --- | --- |
| 1 | Sources: the primary sources for every voice in this plan recorded in the register; Judaism added to the guardrails' list of traditions (B6); References proposals drafted | approve the References additions Q1 to Q13 by id; decision B8 | done 2026-09-21: 110 sources recorded, S14 to S123 |
| 2 | The convergence map: how each tradition stands to each teaching, with sources, in the cross-reference matrix and gated | nothing | done 2026-09-21: 87 cells on 25 teachings |
| 3 | Core beliefs 1, 4, 5, 7 rewritten, and belief 4 renamed (B3). Clears five records: the four pages and the index | approve each page by id; `--accept-core`; `--waive-imbalance` to remove the cleared records | done 2026-09-21, proposals P15 to P20: known imbalances 13 to 7, Islam 25 per cent of the whole text |
| 4 | Core beliefs 2, 3, 6, 8, 9, 10 rewritten. Clears six page records and the section record | the same | done 2026-09-21, proposals P21 to P28: known imbalances 7 to 1, Islam 18 per cent of the whole text, every tradition inside the target ranges |
| 5 | Practice: prayer, holy texts, the meditation introduction, gratitude and mindful action | approve by id | done 2026-09-21, proposals P29 to P36: eight pages, no baseline change |
| 6 | Doctrine and Way of Life: karma, dharma, the pages for Laozi and Guru Nanak (B4), environmental stewardship, sobriety, family, work and service | approve by id; `--accept-core` for the doctrine pages; `--waive-imbalance` for the thirteenth record | done 2026-09-21, proposals P48 to P60: no recorded imbalance remains; Laozi and Guru Nanak have pages; the two pages on death credit the Seicho-No-Ie sutra |
| 7 | Context: Historical Context and Comparative Analysis. Then the tighter caps and the new report lines (B5) | approve by id; the caps | done 2026-09-21, proposals P61 to P63: whole-text cap 25 per cent; the section cap stays at 50, on the measurements |

Steps 3 and 4 can be drafted together and merged in either order. Steps 5 and 6 do not depend on
each other. Step 7 is last because the caps are set from the numbers the earlier steps produce.

## Parked items

Everything set aside while the steps were done, so none of it lives only in a conversation. Each
line says who can move it.

**Sourcing: done on 21 September 2026, as S124 to S194.** Four research agents, almost every page
read directly and not through a summarising tool. What it settled:

- **Buddha-nature** has a scholarly source (S124, S125) and can join belief 4, worded as the
  potential for, or nature of, buddhahood. It is explicitly not a soul.
- **Christian contemplative prayer** is sourced (S150 to S154), so a fourth form of meditation is
  possible, each practice with its caution: Lectio Divina ends in action; the Jesus Prayer asks
  for a spiritual guide; centering prayer is a method of the 1970s that some Catholics criticise.
- **The Canticle line in belief 8 is confirmed** (S155, S156).
- **The claim dropped from belief 10 can return**: Islam on good character (S160, S161) and on
  taqwa, mindfulness of God (S162, S163), whose object is God and not the present moment.
- **The contrary cells are in the convergence map**, each in the tradition's own words: original
  sin, stated three ways (S131 to S134); salvation through Christ, from exclusive to inclusive
  (S135 to S139); marriage in classical Christian, Islamic and Jewish teaching, and the churches
  and movements that now differ (S140 to S143, S169, S176 to S178); the resurrection of the body
  against UPL's cocoon (S144 to S146, S164, S165); eternal punishment and the minority hope against
  it (S157 to S159); Buddhism on a creator (S126 to S128).
- **Innate goodness stands on more than was recorded**: Islam (S170, S171) and Judaism (S174, S175)
  both reject inherited sin.
- **Taoism has cells** (S129, S130), and **the Bahá'í Faith** joins the map (S182 to S186), with
  the caution that it is not simple pluralism.
- **Weak rows replaced**: Te Ara now read (S187); the Thanksgiving Address from two Mohawk bodies
  (S188, S189), since the Confederacy's own site has no page on it; Vivekananda's four yogas
  (S190); Guru Nanak's dates (S191). Image of God and gratitude in Christian sources (S147 to S149),
  gratitude and chosenness in Jewish ones (S172, S173, S179, S180), the Shema (S181), the verses on
  other religions (S166 to S168).
- **The bibliography is checked against catalogues** (S192 to S194 and the Library of Congress).
  Three entries are wrong as listed and one is not a book; corrections are proposed as Q14 to Q17.

Corrections to what had been assumed, recorded so they are not repeated: the poisoned-arrow
discourse does not mention a creator; "the West teaches inherited guilt" is how the Orthodox
describe Rome and not how Rome describes itself; the Catholic position on other religions is
inclusivist and its best-known sentence cannot be quoted without the one after it; Qur'an 17:85
reads "domain" in Abdel Haleem and may not be about the human soul; the current JPS renders the
Shema "the Eternal alone"; the Conservative movement's vote of 2012 was 15 to 0 with 1 abstaining.

Still to source: the modern hope "that all may be saved" (Balthasar, Kallistos Ware); an Orthodox
source on other religions; the classical Sufi texts on watchfulness; the method of centering
prayer; pages 123 to 126 of De Michelis, read in full; primary sources in place of S04, S07, S67,
S83, S86 and S87.

**The author's own words, which a draft can prompt and cannot replace.**

- Example affirmations for the four gratitude pages. An affirmation is what a follower says aloud.
- What Other Practices is meant to list (finding X08).
- The openings that are still fragments outside the ten core beliefs (W1 in the site review), and
  the two accuracy points on the doctrine pages (W3): the hard problem of consciousness called
  "empirically-based", and the observer effect.
- The home page's second paragraph and its link text, `paper/` (S4 in the site review).
- One-sentence `description` front matter for each page (S5), which then lets the contents cards
  carry descriptions (S6).

**Open findings in the cross-reference matrix,** each needing the author's decision: two statements
of the mission (X04); the core belief and the section that share a name, for positive thinking
(X05) and for environmental stewardship (X06); the cocoon image given in full on two pages (X09);
Ummah, Zakat and Tawhid each explained more than once (X10, X11, X12); rituals and celebrations on
two pages with no list of observances (X13); gratitude defined twice (X14); hoʻoponopono glossed
twice (X15); two section introductions ending on the same phrase (X19).

**Still ahead in this plan:** step 6 (doctrine and way of life, with the pages for Laozi and Guru
Nanak), and step 7 (context, then the tighter caps).

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
- **The three Foundations slips.** Beliefs 4 and 7 close in step 3. The Author Note slip
  ("tranquillity") was fixed on 21 September 2026, with the References entries.

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
- It does not write front-matter descriptions (S5 in the site review), though steps 3 and 4 are
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
12. Every tradition named on a rewritten page has a cell in the convergence map with a source,
    and `python3 scripts/check-content-index.py` passes.
13. No page presents a resemblance or a contrary teaching as agreement: each `resembles` and
    `contrary` cell that a page draws on is worded as the cell's note says.

## Acceptance

A reader who opens any of the ten core beliefs meets the belief first and then hears it echoed by
several traditions, none of them louder than the rest. A Buddhist, a Christian, a Hindu, a Jew, a
Muslim or a follower of Seicho-No-Ie finds their tradition described in its own words, accurately,
with its source, and finds that it is neither the measure of the others nor measured by them. The
gate keeps it so.
