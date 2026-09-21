# Cross-reference matrix

The index of the teachings: which page owns each concept, where it is elaborated, where it
is mentioned, and the known overlaps between pages. For anyone adding or changing a page
under `content/`, so that the text does not grow ambiguous, redundant, deprecated or
conflicting content.

This page is written by `scripts/check-content-index.py --render` from
`scripts/content-index.json`. Do not edit it by hand.

## How it works

- **One owner per concept.** The owner page is where the concept is stated. Other pages may
  elaborate it or mention it; they should not restate it, and must not contradict it.
- **Mentions are worked out, not written down.** The script finds them from each concept's
  terms on every run, so this part of the matrix cannot go stale.
- **Every page has a status**, `current` or `deprecated`. A deprecated page names its
  replacement, owns nothing, and no current page may link to it.
- **Overlaps are recorded as findings**, each with a type, a status and a note. `open` means
  undecided, `accepted` means kept on purpose with a reason, `resolved` means fixed.
- **Every page is fingerprinted.** A changed or new page fails `scripts/check.sh` until it
  has been re-read against this matrix and recorded, so the matrix is updated before any
  merge.

## Before you merge a change under `content/`

1. Find the concepts your page touches in the table below and read their owner pages.
2. If your page states a concept that already has an owner, link to the owner instead, or
   move ownership on purpose.
3. A new concept gets an entry in `scripts/content-index.json` with one owner and its terms.
4. Record any overlap you leave in place as a finding. Close the findings you fix.
5. Run `python3 scripts/check-content-index.py --record`, then `bash scripts/check.sh`.

## Concepts

Counts are the number of pages in each part that name the concept.

| Concept | Owner | Elaborated in | foundations | doctrine | practice | way-of-life | context | Pages |
| ------- | ----- | ------------- | ---: | ---: | ---: | ---: | ---: | ----: |
| The name Synphotodosism | [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md) | | 3 | 2 | | 2 | | 8 |
| Mission and vision | [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md) | | 4 | | | | | 4 |
| Purpose | [1-foundations/purpose](../content/1-foundations/purpose.md) | | 3 | 1 | | | 1 | 5 |
| Unity | [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md) | | 6 | 6 | 3 | 4 | 2 | 22 |
| Spiritual evolution and practice | [1-foundations/core-beliefs/spiritual-evolution-and-practice](../content/1-foundations/core-beliefs/spiritual-evolution-and-practice.md) | [3-practice](../content/3-practice/README.md) | 4 | 4 | 4 | 10 | 2 | 24 |
| Ethical and moral living | [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md), [2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice](../content/2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice.md) | 5 | 10 | 1 | 1 | 2 | 19 |
| Family | [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | [4-way-of-life/family](../content/4-way-of-life/family/README.md) | 3 | | 1 | 6 | 1 | 11 |
| Innate goodness (Fitrah) | [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | | 2 | | | | | 2 |
| Compassionate action | [1-foundations/core-beliefs/compassionate-action](../content/1-foundations/core-beliefs/compassionate-action.md) | | 4 | 6 | 2 | 2 | 2 | 16 |
| Interconnectedness | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | [4-way-of-life/environmental-stewardship/principle-of-interconnectedness](../content/4-way-of-life/environmental-stewardship/principle-of-interconnectedness.md) | 4 | 3 | 1 | 4 | 1 | 13 |
| Pursuit of knowledge and continuous learning | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | [4-way-of-life/continuous-learning](../content/4-way-of-life/continuous-learning/README.md) | 4 | 1 | | 7 | 2 | 14 |
| Respect for the wisdom of world traditions | [1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md) | [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md), [3-practice/holy-texts](../content/3-practice/holy-texts.md), [3-practice/prayer](../content/3-practice/prayer.md) | 2 | 2 | 5 | | 2 | 11 |
| Environmental stewardship | [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md) | [4-way-of-life/environmental-stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | 3 | | 2 | 9 | 1 | 15 |
| Community and fellowship | [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md) | [4-way-of-life/community-and-fellowship](../content/4-way-of-life/community-and-fellowship/README.md) | 8 | 4 | 1 | 12 | 2 | 27 |
| Positive thinking | [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md) | [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md), [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | 4 | 2 | 5 | 1 | 1 | 13 |
| Gratitude | [3-practice/gratitude-affirmations](../content/3-practice/gratitude-affirmations/README.md) | [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | 4 | 1 | 11 | | 1 | 17 |
| Mindful action | [3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action.md) | | 3 | 1 | 3 | 1 | 1 | 9 |
| Divine light | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 2 | 8 | 2 | | 1 | 13 |
| God | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 3 | 5 | 1 | | 1 | 10 |
| Quantum physics | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 1 | 2 | | 1 | 2 | 6 |
| Darkness, the lack of light | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | | 1 | | | | 1 |
| Enlightened figures | [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md) | | 1 | 2 | | | 1 | 4 |
| The immortal soul (also spirit, consciousness of the person, true self) | [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md) | 2 | 10 | 1 | 3 | 2 | 18 |
| The silkworm and cocoon image | [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | | | 6 | | | | 6 |
| Karma | [2-doctrine/soul-karma-dharma-and-death/karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md) | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | 1 | 5 | | 1 | 2 | 9 |
| Dharma | [2-doctrine/soul-karma-dharma-and-death/dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md) | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | 1 | 7 | | 1 | 2 | 11 |
| Liberation | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | | 1 | 2 | | | 1 | 4 |
| Death | [2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md) | [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | | 5 | | | 1 | 6 |
| Consciousness | [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | | 3 | 4 | 2 | 1 | 1 | 11 |
| Meditation | [3-practice/meditation](../content/3-practice/meditation/README.md) | | 1 | | 6 | 3 | | 10 |
| Prayer | [3-practice/prayer](../content/3-practice/prayer.md) | | 1 | | 2 | 2 | | 5 |
| Holy texts | [3-practice/holy-texts](../content/3-practice/holy-texts.md) | | | | 2 | 2 | | 4 |
| Rituals and celebrations | [4-way-of-life/community-and-fellowship/community-engagement](../content/4-way-of-life/community-and-fellowship/community-engagement.md) | | | | 1 | 3 | | 5 |
| Marriage | [4-way-of-life/family/marriage](../content/4-way-of-life/family/marriage.md) | | | | | 2 | | 2 |
| Divorce | [4-way-of-life/family/divorce](../content/4-way-of-life/family/divorce.md) | | | | | 2 | | 2 |
| Sobriety | [4-way-of-life/holistic-wellbeing/sobriety](../content/4-way-of-life/holistic-wellbeing/sobriety.md) | | | | | 3 | 1 | 4 |
| Science and modern medicine | [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md) | | | | | 2 | | 2 |
| Science and technology | [4-way-of-life/continuous-learning/sciences-and-technology](../content/4-way-of-life/continuous-learning/sciences-and-technology.md) | | | 1 | 1 | 6 | 2 | 10 |
| Arts and creativity | [4-way-of-life/continuous-learning/arts-and-creative-expression](../content/4-way-of-life/continuous-learning/arts-and-creative-expression.md) | | | 1 | | 4 | 1 | 6 |
| Tawhid | [2-doctrine/enlightened-figures/muhammad](../content/2-doctrine/enlightened-figures/muhammad.md) | | 1 | 1 | | | 1 | 3 |
| Ummah | [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md) | | 2 | | | | | 2 |
| Zakat | [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | | 1 | 1 | | | | 2 |
| Eightfold Path | [2-doctrine/ethical-and-moral-development/diverse-ethical-teachings](../content/2-doctrine/ethical-and-moral-development/diverse-ethical-teachings.md) | | | 2 | | | | 2 |
| Seicho-No-Ie | [2-doctrine/enlightened-figures/masaharu-taniguchi](../content/2-doctrine/enlightened-figures/masaharu-taniguchi.md) | | | 3 | 2 | 1 | 1 | 7 |
| Shinsokan | [3-practice/meditation/shinsokan-meditation](../content/3-practice/meditation/shinsokan-meditation.md) | | | | 2 | | | 2 |
| Ho'oponopono | [3-practice/meditation/hooponopono-meditation](../content/3-practice/meditation/hooponopono-meditation.md) | | | | 3 | 1 | | 4 |
| Pantheism | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md) | | | | | | 2 | 2 |
| Socinianism | [5-context/historical-context](../content/5-context/historical-context.md) | | | | | | 2 | 2 |

## Convergence map

Which traditions hold each teaching, and how. A teaching shared by several traditions is
one teaching, not several voices, and the pages are written that way. Every cell rests on
a source in the [source register](sources.md).

- **O, origin.** The teaching comes from this tradition.
- **I, inherits.** This tradition took it from another, which is credited first.
- **H, holds independently.** This tradition teaches it in its own right.
- **R, resembles only.** It has something that looks alike and is not the same. Never
  written as agreement.
- **C, contrary.** It teaches otherwise. Said openly, in Comparative Analysis.

| Teaching | Hinduism | Islam | Christianity | Sikhism | Seicho-no-Ie | Buddhism | Judaism | Indigenous traditions | Hawaiian tradition | Shared by |
| --- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | ---: |
| Unity | H | H | H | H | H | | | | | 5 |
| Spiritual evolution and practice | H | H | H | | H | H | H | | | 6 |
| Ethical and moral living | H | H | H | H | | H | H | | | 6 |
| Innate goodness (Fitrah) | | O | | | H | R | H | | | 3 |
| Compassionate action | H | H | I | H | | H | O | | | 6 |
| Interconnectedness | H | | | | H | H | | H | H | 5 |
| Pursuit of knowledge and continuous learning | H | H | | | | H | H | | | 4 |
| Respect for the wisdom of world traditions | R | H | | | H | R | | | | 2 |
| Environmental stewardship | | H | H | | H | | H | H | H | 6 |
| Community and fellowship | | H | H | H | | H | | | | 4 |
| Positive thinking | | H | R | | O | R | | | | 2 |
| Gratitude | | H | | | H | | | H | | 3 |
| Mindful action | H | | H | | | H | H | | | 4 |
| Divine light | H | H | H | H | H | | R | | | 5 |
| The immortal soul (also spirit, consciousness of the person, true self) | H | | | | H | C | | | | 2 |
| The silkworm and cocoon image | | | | | O | | | | | 1 |
| Karma | O | | | | | | | | | 1 |
| Dharma | O | | | | | R | | | | 1 |
| Death | | | C | | | | | | | 0 |
| Prayer | H | H | H | | | | | | | 3 |
| Holy texts | | | H | | | H | | | | 2 |
| Sobriety | | | | H | | H | | | | 2 |
| Science and modern medicine | | | R | | C | | H | | | 1 |
| Shinsokan | | | | | O | | | | | 1 |
| Ho'oponopono | | | | | | | | | O | 1 |

How many of these teachings each tradition shares in, resembles or stands against. This is
the second measure of balance, beside the count of mentions: it shows where a tradition
truly meets the teachings and where it does not.

| Tradition | Shares in | Of which origin | Resembles only | Contrary |
| --- | ---: | ---: | ---: | ---: |
| Hinduism | 12 | 2 | 1 | |
| Islam | 13 | 1 | | |
| Christianity | 10 | | 2 | 1 |
| Sikhism | 6 | | | |
| Seicho-no-Ie | 12 | 3 | | 1 |
| Buddhism | 9 | | 4 | 1 |
| Judaism | 8 | 1 | 1 | |
| Indigenous traditions | 3 | | | |
| Hawaiian tradition | 3 | 1 | | |

### The cells

**Unity**, owned by [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hinduism | independent | S64 | "That thou art". Identity of self and ultimate reality is one school's reading of three. |
| Islam | independent | S88, S101 | The oneness of God, and God as the Light of the heavens and the earth. |
| Christianity | independent | S32, S44 | "You are the light of the world" and "God is light" are different sayings with different subjects. |
| Sikhism | independent | S103, S110 | One creator, and the Lord's Light within all. |
| Seicho-no-Ie | independent | S05, S06 | Only the perfect world God created truly exists. |

**Spiritual evolution and practice**, owned by [1-foundations/core-beliefs/spiritual-evolution-and-practice](../content/1-foundations/core-beliefs/spiritual-evolution-and-practice.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S92 | Prayer, fasting and pilgrimage among the five. |
| Hinduism | independent | S56, S57 | Paths of action, knowledge and devotion for different temperaments. The fourfold scheme is modern (S58). |
| Buddhism | independent | S69, S85 | The eightfold path; mindfulness of breathing as a path to liberation. |
| Christianity | independent | S33 | Giving, prayer and fasting, done in secret. |
| Judaism | independent | S28, S24 | The day of rest; study. |
| Seicho-no-Ie | independent | S115 | Shinsokan, a prayerful meditation. |

**Ethical and moral living**, owned by [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Judaism | independent | S18, S19 | Tzedakah: righteousness and charity, both. |
| Islam | independent | S91 | Zakat, an obligation, and not only relief of the poor. |
| Christianity | independent | S38, S32 | The least of these; the merciful and the peacemakers. |
| Hinduism | independent | S59, S61, S62 | Non-injury as a virtue. Not general pacifism. |
| Buddhism | independent | S70, S77 | Right speech and action; the five precepts. |
| Sikhism | independent | S106 | Work for what you eat and give some of what you have. |

**Innate goodness (Fitrah)**, owned by [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | origin | S89 | The word and the teaching as the page uses it. Cite the verse; the hadith (S90) names other traditions. |
| Judaism | independent | S22 | Made in the image of God. |
| Seicho-no-Ie | independent | S05 | Already perfect, a child of God. |
| Buddhism | resembles | S83, S84 | Buddha-nature is a Mahayana teaching of the potential for awakening, contested within Mahayana, and not the goodness of a soul. Needs a further source. |

**Compassionate action**, owned by [1-foundations/core-beliefs/compassionate-action](../content/1-foundations/core-beliefs/compassionate-action.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Judaism | origin | S14, S15, S16, S17 | Love your neighbour, read with love the stranger; Hillel's rule, quoted whole. |
| Christianity | inherits from Judaism | S37, S40, S32 | Jesus quotes Leviticus; the Samaritan widens the neighbour; love of enemies. |
| Islam | independent | S99, S100 | Against those who drive away the orphan; the merciful are shown mercy. |
| Buddhism | independent | S72, S73 | Love, compassion, rejoicing and equanimity. |
| Hinduism | independent | S61, S62 | |
| Sikhism | independent | S109 | Seva. |

**Interconnectedness**, owned by [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Buddhism | independent | S75, S76 | The Huayan school's net of Indra and Thich Nhat Hanh's interbeing. Early dependent origination (S74) explains the arising of suffering and only resembles this. |
| Hinduism | independent | S65 | The whole world as a family: a late text about a detached sage. |
| Indigenous traditions | independent | S119, S120 | Māori kaitiakitanga; the Haudenosaunee Thanksgiving Address. Each is that people's own, not a general ethic. |
| Hawaiian tradition | independent | S121 | Aloha ʻāina and mālama ʻāina, political as well as ecological. |
| Seicho-no-Ie | independent | S117 | Grand Harmony of God, Nature, and Human Beings. |

**Pursuit of knowledge and continuous learning**, owned by [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S95 | "My Lord, increase me in knowledge". The well-known hadith (S94) has a very weak chain. |
| Judaism | independent | S23, S24 | Study, and dispute for the sake of Heaven. |
| Buddhism | independent | S79, S80 | Test a teaching by its fruits and by what the wise praise. Not a licence to believe what one likes. |
| Hinduism | independent | S56 | The path of knowledge. |

**Respect for the wisdom of world traditions**, owned by [1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Seicho-no-Ie | independent | S113 | All religions emanate from one universal God. The nearest statement of UPL's own premise. |
| Islam | independent | S93 | One community, said after a list of earlier prophets. Translations differ. |
| Hinduism | resembles | S51 | "To what is One, sages give many a title" names Vedic gods. Reading it as a statement about all religions is modern. |
| Buddhism | resembles | S81 | The teaching as a raft, a means and not an end. It is about the Buddha's own teaching, not about other religions. |

**Environmental stewardship**, owned by [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S96, S97 | Successors upon the earth, often understood as stewardship; do not be excessive. |
| Judaism | independent | S20, S21 | Do not destroy: a rabbinic extension of a verse on fruit trees. The environmental reading is modern. |
| Christianity | independent | S46, S47 | Francis of Assisi, patron of those who promote ecology; the Canticle of the Creatures. |
| Indigenous traditions | independent | S119, S120 | |
| Hawaiian tradition | independent | S121 | |
| Seicho-no-Ie | independent | S117 | |

**Community and fellowship**, owned by [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S93 | The ummah. |
| Buddhism | independent | S86, S78 | The Sangha: in the early texts the monastic order or the community of the awakened. |
| Christianity | independent | S43, S39 | Washing one another's feet; whoever would be great shall serve. |
| Sikhism | independent | S107, S108, S109 | The shared meal open to all, and seva. Traditionally traced to Guru Nanak. |

**Positive thinking**, owned by [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Seicho-no-Ie | origin | S113 | The law of the mind: thought, word and deed shape the phenomenal world. |
| Islam | independent | S98 | Gratitude, which is sourced. The page also credits Islam with positive conduct and mindful awareness, for which no source is recorded yet. |
| Buddhism | resembles | S68 | Mind or intention comes first, leading speech and action. It does not say thoughts create reality. |
| Christianity | resembles | S33 | Do not be anxious: trust, turning on "seek first God's Kingdom", not the power of thought. |

**Gratitude**, owned by [3-practice/gratitude-affirmations](../content/3-practice/gratitude-affirmations/README.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S98 | Gratitude is met with increase. |
| Indigenous traditions | independent | S120 | Thanks to each part of the natural world, before all else. |
| Seicho-no-Ie | independent | S114, S116 | Reconciliation with all things; gratitude to ancestors. The English wording of the Grand Harmony message is not to be quoted yet. |

**Mindful action**, owned by [3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hinduism | independent | S53 | A right to the work, not to its fruits. |
| Buddhism | independent | S70, S71 | |
| Christianity | independent | S33 | Done in secret, not for show. |
| Judaism | independent | S26 | The ethics of speech. |

**Divine light**, owned by [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Islam | independent | S101 | The Light Verse. |
| Christianity | independent | S32, S42, S44 | |
| Sikhism | independent | S110 | |
| Hinduism | independent | S64, S52 | From darkness lead me to light. |
| Seicho-no-Ie | independent | S05 | The person as a child of God. UPL credits the phrase and keeps its own (decision D1). |
| Judaism | resembles | S22 | Humankind in the image of God. The verse does not say what the image is; the mystical teaching of divine sparks is not recorded here and is to be described, not absorbed. |

**The immortal soul (also spirit, consciousness of the person, true self)**, owned by [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hinduism | independent | S64 | The atman. |
| Seicho-no-Ie | independent | S05 | Man is not matter but spiritual existence. |
| Buddhism | contrary | S82 | Nothing in body or mind is a permanent, unchanging self. UPL parts from Buddhism here and says so (decision D3). |

**The silkworm and cocoon image**, owned by [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Seicho-no-Ie | origin | S07, S08 | The silkworm and the cocoon, from the Nectarean Shower of Holy Doctrines. |

**Karma**, owned by [2-doctrine/soul-karma-dharma-and-death/karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hinduism | origin | S53 | Action and its fruit. |

**Dharma**, owned by [2-doctrine/soul-karma-dharma-and-death/dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hinduism | origin | S54, S55, S63, S67 | One's own dharma is bound to the four classes in the text. UPL takes the path of right action and not the assignment by birth. |
| Buddhism | resembles | S87 | In Buddhism the dharma is the teaching and the truth it points to. The same word, a different sense. |

**Death**, owned by [2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Christianity | contrary | S38 | The passage on the least of these ends in eternal punishment, which UPL does not teach. |

**Prayer**, owned by [3-practice/prayer](../content/3-practice/prayer.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Christianity | independent | S33 | The Lord's Prayer, without the later doxology. |
| Islam | independent | S102 | |
| Hinduism | independent | S52 | |

**Holy texts**, owned by [3-practice/holy-texts](../content/3-practice/holy-texts.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Buddhism | independent | S79, S81 | |
| Christianity | independent | S48, S49, S50 | Allegorical reading: one major strand, and Augustine warns against it as well as for it. |

**Sobriety**, owned by [4-way-of-life/holistic-wellbeing/sobriety](../content/4-way-of-life/holistic-wellbeing/sobriety.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Buddhism | independent | S77, S78 | The fifth precept. |
| Sikhism | independent | S107 | No intoxicant, in the Sikh code of conduct. |

**Science and modern medicine**, owned by [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Judaism | independent | S03, S04 | Saving a life comes before almost every other duty. |
| Christianity | resembles | S35 | Healing with a word, read as teaching about faith and not as a technique. |
| Seicho-no-Ie | contrary | S115 | In the True Image there is no disease. UPL holds that illness is real and is treated (decisions D1 and D2). |

**Shinsokan**, owned by [3-practice/meditation/shinsokan-meditation](../content/3-practice/meditation/shinsokan-meditation.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Seicho-no-Ie | origin | S115 | |

**Ho'oponopono**, owned by [3-practice/meditation/hooponopono-meditation](../content/3-practice/meditation/hooponopono-meditation.md)

| Tradition | Relation | Sources | Note |
| --- | --- | --- | --- |
| Hawaiian tradition | origin | S122 | To set right: a family process led by a respected mediator. The four-phrase form is a modern adaptation. |

## Findings

### Open

| Id | Type | Pages | Note |
| -- | ---- | ----- | ---- |
| X04 | ambiguous | [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md), [1-foundations/purpose](../content/1-foundations/purpose.md) | Two statements of the mission. Name, Mission, and Vision names compassion, wisdom and enlightenment through unity, ethical living and continuous learning; Purpose says the mission "pivots around" freedom, acceptance, ethical living, love and continuous spiritual growth. |
| X05 | ambiguous | [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md), [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md) | The core belief and the practice section carry almost the same title and do not link to each other. A reader or a search engine cannot tell which is the statement and which the elaboration. |
| X06 | ambiguous | [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md), [4-way-of-life/environmental-stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | The core belief and the way-of-life section share a name and do not link to each other. |
| X07 | ambiguous | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md), [4-way-of-life/environmental-stewardship/principle-of-interconnectedness](../content/4-way-of-life/environmental-stewardship/principle-of-interconnectedness.md) | Two pages are named for interconnectedness. The core belief names it only in its title and speaks of knowledge; the other treats it only for nature. No page states the concept in general. |
| X08 | ambiguous | [3-practice/other-practices](../content/3-practice/other-practices.md), [3-practice](../content/3-practice/README.md) | Other Practices is a general statement about practice, which the part introduction already gives. Its title promises a list it does not contain. |
| X09 | redundant | [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md), [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | The silkworm and cocoon image is given in full on both pages, a result of splitting the paper. The image is now credited on The Immortal Soul to Taniguchi's Nectarean Shower of Holy Doctrines (source S07). |
| X10 | redundant | [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md), [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | Ummah is explained on both pages. |
| X11 | redundant | [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md), [2-doctrine/ethical-and-moral-development/diverse-ethical-teachings](../content/2-doctrine/ethical-and-moral-development/diverse-ethical-teachings.md) | Zakat is explained on both pages. |
| X12 | redundant | [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md), [2-doctrine/enlightened-figures/muhammad](../content/2-doctrine/enlightened-figures/muhammad.md), [5-context/historical-context](../content/5-context/historical-context.md) | Tawhid is explained on the first two pages and named again on the third. |
| X13 | redundant | [4-way-of-life/community-and-fellowship/community-engagement](../content/4-way-of-life/community-and-fellowship/community-engagement.md), [4-way-of-life/environmental-stewardship/mindful-interaction-with-the-environment](../content/4-way-of-life/environmental-stewardship/mindful-interaction-with-the-environment.md) | Both pages have a subsection on rituals and celebrations. They do not disagree, but neither points to the other, and no page lists the observances. |
| X14 | redundant | [3-practice/gratitude-affirmations](../content/3-practice/gratitude-affirmations/README.md), [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | Both pages define gratitude as a spiritual discipline in similar words. |
| X15 | redundant | [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md), [3-practice/meditation/hooponopono-meditation](../content/3-practice/meditation/hooponopono-meditation.md) | Ho'oponopono is glossed as reconciliation and forgiveness on both pages. |
| X19 | redundant | [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md), [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md) | Both section introductions end on the same phrase, "the soul's progression towards enlightenment and unity with the divine". Found by the wording check, not by reading. |

### Accepted

| Id | Type | Pages | Note |
| -- | ---- | ----- | ---- |
| X16 | redundant | [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md), [2-doctrine/ethical-and-moral-development/diverse-ethical-teachings](../content/2-doctrine/ethical-and-moral-development/diverse-ethical-teachings.md) | The section introduction lists the four sources of ethics that the page under it then treats one by one. Reason kept: An introduction that previews its section. Keep the two lists in step. |
| X17 | redundant | [README](../content/README.md), [1-foundations/abstract](../content/1-foundations/abstract.md), [5-context/conclusion](../content/5-context/conclusion.md) | The home page, the Abstract and the Conclusion each summarise the whole. The home page's first sentence repeats the Abstract's. Reason kept: These are the summary pages of the founding paper. A change of doctrine must be carried into all three. |
| X18 | redundant | [README](../content/README.md), `site/src/lib/site.ts` | The site configuration holds its own one-paragraph summary of the religion, used in llms.txt and structured data. It is a description, not a teaching, but it is doctrine-shaped text outside content/ and can drift from it. Reason kept: Machine-facing metadata, allowed by locked decision 3. Re-read it whenever the home page or the Abstract changes. |

### Resolved

| Id | Type | Pages | Note |
| -- | ---- | ----- | ---- |
| X01 | conflicting | [4-way-of-life/holistic-wellbeing](../content/4-way-of-life/holistic-wellbeing/README.md), [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md) | Resolved 21 September 2026 by decision D2 and proposals P1 and P2: the introduction now says "trust in science and modern medicine", and the page states that UPL heals the spirit, medicine treats the body, and a follower never relies on spiritual or alternative remedies alone. |
| X02 | conflicting | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md), [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md), [1-foundations/author-note](../content/1-foundations/author-note.md) | Resolved 21 September 2026 by decision D1 and proposals P4 to P9: God is not a person but the source of light. Comparative Analysis and the God page now say so, "God's love" is explained as the nature of the light, "divine will" became "divine order", and prayer is attunement. Unity still describes Tawhid in Islam's own terms, which is a description of Islam and not of UPL's God. |
| X03 | conflicting | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md), [2-doctrine/enlightened-figures/buddha](../content/2-doctrine/enlightened-figures/buddha.md) | Resolved 21 September 2026 by decision D3 and proposal P3: Comparative Analysis now honours the Buddha's teaching that suffering can be understood and ended, and states openly that UPL parts from Buddhism on the self. |

## Pages

| Page | Status | Owns | Also names |
| ---- | ------ | ---- | ---------- |
| [1-foundations](../content/1-foundations/README.md) | current | | Mission and vision, Purpose |
| [1-foundations/abstract](../content/1-foundations/abstract.md) | current | | The name Synphotodosism, Unity, Spiritual evolution and practice, Ethical and moral living, Interconnectedness, Pursuit of knowledge and continuous learning, Community and fellowship, Positive thinking, Gratitude, Mindful action, Quantum physics, The immortal soul (also spirit, consciousness of the person, true self), Karma, Dharma, Consciousness |
| [1-foundations/author-note](../content/1-foundations/author-note.md) | current | | Mission and vision, Unity, Community and fellowship, Gratitude, God |
| [1-foundations/core-beliefs](../content/1-foundations/core-beliefs/README.md) | current | | Unity, Spiritual evolution and practice, Ethical and moral living, Family, Innate goodness (Fitrah), Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Environmental stewardship, Community and fellowship, Positive thinking, Gratitude, Mindful action |
| [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md) | current | Community and fellowship, Ummah | Environmental stewardship |
| [1-foundations/core-beliefs/compassionate-action](../content/1-foundations/core-beliefs/compassionate-action.md) | current | Compassionate action | Family, Community and fellowship |
| [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md) | current | Environmental stewardship | God |
| [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | current | Ethical and moral living, Zakat | Compassionate action, Community and fellowship, Ummah |
| [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | current | Family, Innate goodness (Fitrah) | |
| [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | current | Interconnectedness, Pursuit of knowledge and continuous learning | |
| [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md) | current | Positive thinking | Gratitude, Mindful action |
| [1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md) | current | Respect for the wisdom of world traditions | Enlightened figures |
| [1-foundations/core-beliefs/spiritual-evolution-and-practice](../content/1-foundations/core-beliefs/spiritual-evolution-and-practice.md) | current | Spiritual evolution and practice | Unity, Community and fellowship, Meditation, Prayer |
| [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md) | current | Unity | Divine light, God, Consciousness, Tawhid |
| [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md) | current | The name Synphotodosism, Mission and vision | Purpose, Unity, Ethical and moral living, Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Community and fellowship, Positive thinking, Divine light, The immortal soul (also spirit, consciousness of the person, true self) |
| [1-foundations/purpose](../content/1-foundations/purpose.md) | current | Purpose | The name Synphotodosism, Mission and vision, Spiritual evolution and practice, Ethical and moral living, Liberation, Consciousness |
| [2-doctrine](../content/2-doctrine/README.md) | current | | Ethical and moral living, Divine light, God, Quantum physics, Enlightened figures, The immortal soul (also spirit, consciousness of the person, true self), Karma, Dharma, Death |
| [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md) | current | Enlightened figures | Unity, Ethical and moral living, Compassionate action, Respect for the wisdom of world traditions, Positive thinking, Divine light, God |
| [2-doctrine/enlightened-figures/buddha](../content/2-doctrine/enlightened-figures/buddha.md) | current | | Spiritual evolution and practice, Ethical and moral living, Compassionate action, Interconnectedness |
| [2-doctrine/enlightened-figures/jesus](../content/2-doctrine/enlightened-figures/jesus.md) | current | | The name Synphotodosism, Compassionate action, Interconnectedness, Community and fellowship, Divine light |
| [2-doctrine/enlightened-figures/masaharu-taniguchi](../content/2-doctrine/enlightened-figures/masaharu-taniguchi.md) | current | Seicho-No-Ie | Unity, Positive thinking, Divine light, The immortal soul (also spirit, consciousness of the person, true self) |
| [2-doctrine/enlightened-figures/muhammad](../content/2-doctrine/enlightened-figures/muhammad.md) | current | Tawhid | Unity, Ethical and moral living, Compassionate action, Pursuit of knowledge and continuous learning, Community and fellowship, God |
| [2-doctrine/enlightened-figures/other-spiritual-leaders](../content/2-doctrine/enlightened-figures/other-spiritual-leaders.md) | current | | Unity, Divine light, God |
| [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md) | current | | Unity, Spiritual evolution and practice, Ethical and moral living, Respect for the wisdom of world traditions, Community and fellowship, The immortal soul (also spirit, consciousness of the person, true self), Dharma, Eightfold Path |
| [2-doctrine/ethical-and-moral-development/diverse-ethical-teachings](../content/2-doctrine/ethical-and-moral-development/diverse-ethical-teachings.md) | current | Eightfold Path | The name Synphotodosism, Spiritual evolution and practice, Ethical and moral living, Compassionate action, Community and fellowship, Dharma, Zakat |
| [2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice](../content/2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice.md) | current | | Spiritual evolution and practice, Ethical and moral living, Compassionate action, Divine light |
| [2-doctrine/ethical-and-moral-development/fabric-of-ethics](../content/2-doctrine/ethical-and-moral-development/fabric-of-ethics.md) | current | | Ethical and moral living, The immortal soul (also spirit, consciousness of the person, true self) |
| [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | current | Divine light, God, Quantum physics, Darkness, the lack of light | Ethical and moral living, Interconnectedness, Gratitude, Mindful action, Karma, Dharma, Consciousness, Science and technology, Arts and creativity, Seicho-No-Ie |
| [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md) | current | | Unity, The immortal soul (also spirit, consciousness of the person, true self), The silkworm and cocoon image, Karma, Dharma, Liberation, Death, Consciousness |
| [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | current | Consciousness | The silkworm and cocoon image, Death |
| [2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md) | current | Death | The immortal soul (also spirit, consciousness of the person, true self) |
| [2-doctrine/soul-karma-dharma-and-death/dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md) | current | Dharma | Purpose, The immortal soul (also spirit, consciousness of the person, true self), The silkworm and cocoon image |
| [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | current | The immortal soul (also spirit, consciousness of the person, true self), The silkworm and cocoon image | Divine light, Death, Consciousness, Seicho-No-Ie |
| [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | current | Liberation | The immortal soul (also spirit, consciousness of the person, true self), The silkworm and cocoon image, Karma, Dharma |
| [2-doctrine/soul-karma-dharma-and-death/karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md) | current | Karma | Ethical and moral living, The immortal soul (also spirit, consciousness of the person, true self), The silkworm and cocoon image |
| [3-practice](../content/3-practice/README.md) | current | | Spiritual evolution and practice, Respect for the wisdom of world traditions, Positive thinking, Gratitude, Mindful action, Meditation, Prayer, Holy texts, Rituals and celebrations |
| [3-practice/gratitude-affirmations](../content/3-practice/gratitude-affirmations/README.md) | current | Gratitude | Unity, Environmental stewardship |
| [3-practice/gratitude-affirmations/earth-and-environment](../content/3-practice/gratitude-affirmations/earth-and-environment.md) | current | | Environmental stewardship, Gratitude |
| [3-practice/gratitude-affirmations/gift-of-life](../content/3-practice/gratitude-affirmations/gift-of-life.md) | current | | Spiritual evolution and practice, Gratitude |
| [3-practice/gratitude-affirmations/lifes-blessings](../content/3-practice/gratitude-affirmations/lifes-blessings.md) | current | | Gratitude, Consciousness, Science and technology |
| [3-practice/gratitude-affirmations/relationships](../content/3-practice/gratitude-affirmations/relationships.md) | current | | Family, Community and fellowship, Gratitude |
| [3-practice/holy-texts](../content/3-practice/holy-texts.md) | current | Holy texts | Respect for the wisdom of world traditions |
| [3-practice/meditation](../content/3-practice/meditation/README.md) | current | Meditation | Shinsokan, Ho'oponopono |
| [3-practice/meditation/buddhist-meditation](../content/3-practice/meditation/buddhist-meditation.md) | current | | Spiritual evolution and practice, Compassionate action, Meditation |
| [3-practice/meditation/hooponopono-meditation](../content/3-practice/meditation/hooponopono-meditation.md) | current | Ho'oponopono | Positive thinking, Gratitude, Meditation |
| [3-practice/meditation/shinsokan-meditation](../content/3-practice/meditation/shinsokan-meditation.md) | current | Shinsokan | Unity, Interconnectedness, Meditation, Seicho-No-Ie |
| [3-practice/other-practices](../content/3-practice/other-practices.md) | current | | Spiritual evolution and practice, Ethical and moral living, Respect for the wisdom of world traditions |
| [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md) | current | | Respect for the wisdom of world traditions, Positive thinking, Gratitude, Mindful action, Consciousness, Meditation, Seicho-No-Ie, Ho'oponopono |
| [3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action.md) | current | Mindful action | Compassionate action, Positive thinking, Gratitude, Divine light |
| [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | current | | Positive thinking, Gratitude, The immortal soul (also spirit, consciousness of the person, true self) |
| [3-practice/prayer](../content/3-practice/prayer.md) | current | Prayer | Unity, Respect for the wisdom of world traditions, Gratitude, Divine light, God |
| [4-way-of-life](../content/4-way-of-life/README.md) | current | | Unity, Family, Pursuit of knowledge and continuous learning, Environmental stewardship, Community and fellowship, Sobriety, Science and technology, Arts and creativity |
| [4-way-of-life/community-and-fellowship](../content/4-way-of-life/community-and-fellowship/README.md) | current | | Spiritual evolution and practice, Interconnectedness, Community and fellowship, Prayer, Seicho-No-Ie, Ho'oponopono |
| [4-way-of-life/community-and-fellowship/community-engagement](../content/4-way-of-life/community-and-fellowship/community-engagement.md) | current | Rituals and celebrations | Family, Environmental stewardship, Community and fellowship, Positive thinking, Mindful action, Karma, Dharma, Meditation, Prayer, Holy texts |
| [4-way-of-life/community-and-fellowship/global-spiritual-network](../content/4-way-of-life/community-and-fellowship/global-spiritual-network.md) | current | | Interconnectedness, Community and fellowship, Meditation, Science and technology |
| [4-way-of-life/community-and-fellowship/role-of-community](../content/4-way-of-life/community-and-fellowship/role-of-community.md) | current | | Unity, Spiritual evolution and practice, Compassionate action, Community and fellowship |
| [4-way-of-life/continuous-learning](../content/4-way-of-life/continuous-learning/README.md) | current | | Spiritual evolution and practice, Pursuit of knowledge and continuous learning, Community and fellowship, Science and technology, Arts and creativity |
| [4-way-of-life/continuous-learning/arts-and-creative-expression](../content/4-way-of-life/continuous-learning/arts-and-creative-expression.md) | current | Arts and creativity | Pursuit of knowledge and continuous learning, Environmental stewardship, Community and fellowship, The immortal soul (also spirit, consciousness of the person, true self) |
| [4-way-of-life/continuous-learning/professional-development](../content/4-way-of-life/continuous-learning/professional-development.md) | current | | Pursuit of knowledge and continuous learning |
| [4-way-of-life/continuous-learning/sciences-and-technology](../content/4-way-of-life/continuous-learning/sciences-and-technology.md) | current | Science and technology | Pursuit of knowledge and continuous learning, Environmental stewardship, Arts and creativity |
| [4-way-of-life/environmental-stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | current | | Spiritual evolution and practice, Interconnectedness, Environmental stewardship, Community and fellowship |
| [4-way-of-life/environmental-stewardship/education-and-community-involvement](../content/4-way-of-life/environmental-stewardship/education-and-community-involvement.md) | current | | Pursuit of knowledge and continuous learning, Environmental stewardship, Community and fellowship, Consciousness |
| [4-way-of-life/environmental-stewardship/mindful-interaction-with-the-environment](../content/4-way-of-life/environmental-stewardship/mindful-interaction-with-the-environment.md) | current | | Environmental stewardship, Rituals and celebrations |
| [4-way-of-life/environmental-stewardship/principle-of-interconnectedness](../content/4-way-of-life/environmental-stewardship/principle-of-interconnectedness.md) | current | | The name Synphotodosism, Interconnectedness |
| [4-way-of-life/environmental-stewardship/spiritual-dimension](../content/4-way-of-life/environmental-stewardship/spiritual-dimension.md) | current | | The name Synphotodosism, Unity, Environmental stewardship, Meditation |
| [4-way-of-life/family](../content/4-way-of-life/family/README.md) | current | | Unity, Spiritual evolution and practice, Family, Community and fellowship, Marriage, Divorce |
| [4-way-of-life/family/cooperative-growth-and-support](../content/4-way-of-life/family/cooperative-growth-and-support.md) | current | | Spiritual evolution and practice, Family |
| [4-way-of-life/family/divorce](../content/4-way-of-life/family/divorce.md) | current | Divorce | Spiritual evolution and practice, Family, Compassionate action |
| [4-way-of-life/family/inclusive-familial-structures](../content/4-way-of-life/family/inclusive-familial-structures.md) | current | | Family |
| [4-way-of-life/family/marriage](../content/4-way-of-life/family/marriage.md) | current | Marriage | Spiritual evolution and practice, Community and fellowship |
| [4-way-of-life/holistic-wellbeing](../content/4-way-of-life/holistic-wellbeing/README.md) | current | | Spiritual evolution and practice, Ethical and moral living, Sobriety, Science and modern medicine, Science and technology |
| [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md) | current | Science and modern medicine | Spiritual evolution and practice, Pursuit of knowledge and continuous learning, Community and fellowship, Quantum physics, The immortal soul (also spirit, consciousness of the person, true self), Holy texts, Science and technology |
| [4-way-of-life/holistic-wellbeing/sobriety](../content/4-way-of-life/holistic-wellbeing/sobriety.md) | current | Sobriety | Environmental stewardship, The immortal soul (also spirit, consciousness of the person, true self), Rituals and celebrations |
| [5-context](../content/5-context/README.md) | current | | |
| [5-context/comparative-analysis](../content/5-context/comparative-analysis.md) | current | Pantheism | Spiritual evolution and practice, Ethical and moral living, Compassionate action, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Community and fellowship, God, The immortal soul (also spirit, consciousness of the person, true self), Karma, Dharma, Science and technology |
| [5-context/conclusion](../content/5-context/conclusion.md) | current | | Purpose, Unity, Spiritual evolution and practice, Ethical and moral living, Family, Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Environmental stewardship, Community and fellowship, Positive thinking, Gratitude, Mindful action, Divine light, Quantum physics, Enlightened figures, The immortal soul (also spirit, consciousness of the person, true self), Karma, Dharma, Liberation, Sobriety, Science and technology, Arts and creativity |
| [5-context/historical-context](../content/5-context/historical-context.md) | current | Socinianism | Tawhid, Pantheism |
| [5-context/references](../content/5-context/references.md) | current | | Unity, Quantum physics, Death, Consciousness, Seicho-No-Ie, Socinianism |
| [README](../content/README.md) | current | | The name Synphotodosism, Unity, Rituals and celebrations |
