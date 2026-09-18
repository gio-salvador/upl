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
| Ethical and moral living | [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md), [2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice](../content/2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice.md) | 5 | 9 | 1 | 1 | 2 | 18 |
| Family | [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | [4-way-of-life/family](../content/4-way-of-life/family/README.md) | 3 | | 1 | 6 | 1 | 11 |
| Fitrah | [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | | 2 | | | | | 2 |
| Compassionate action | [1-foundations/core-beliefs/compassionate-action](../content/1-foundations/core-beliefs/compassionate-action.md) | | 4 | 6 | 2 | 2 | 1 | 15 |
| Interconnectedness | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | [4-way-of-life/environmental-stewardship/principle-of-interconnectedness](../content/4-way-of-life/environmental-stewardship/principle-of-interconnectedness.md) | 4 | 3 | 1 | 4 | 1 | 13 |
| Pursuit of knowledge and continuous learning | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | [4-way-of-life/continuous-learning](../content/4-way-of-life/continuous-learning/README.md) | 4 | 1 | | 7 | 2 | 14 |
| Respect for the wisdom of world traditions | [1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md) | [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md), [3-practice/holy-texts](../content/3-practice/holy-texts.md), [3-practice/prayer](../content/3-practice/prayer.md) | 2 | 2 | 5 | | 2 | 11 |
| Environmental stewardship | [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md) | [4-way-of-life/environmental-stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | 3 | | 2 | 9 | 1 | 15 |
| Community and fellowship | [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md) | [4-way-of-life/community-and-fellowship](../content/4-way-of-life/community-and-fellowship/README.md) | 8 | 4 | 1 | 12 | 2 | 27 |
| Positive thinking | [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md) | [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md), [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | 4 | 2 | 5 | 1 | 1 | 13 |
| Gratitude | [3-practice/gratitude-affirmations](../content/3-practice/gratitude-affirmations/README.md) | [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | 4 | | 11 | | 1 | 16 |
| Mindful action | [3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/mindful-action.md) | | 3 | | 3 | 1 | 1 | 8 |
| Divine light | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 2 | 8 | 1 | | 1 | 12 |
| God | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 3 | 5 | | | 1 | 9 |
| Quantum physics | [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | | 1 | 2 | | | 2 | 5 |
| Enlightened figures | [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md) | | 1 | 2 | | | 1 | 4 |
| The immortal soul | [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md) | 2 | 9 | 1 | 1 | 1 | 14 |
| The silkworm and cocoon image | [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | | | 6 | | | | 6 |
| Karma | [2-doctrine/soul-karma-dharma-and-death/karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md) | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | 1 | 4 | | 1 | 2 | 8 |
| Dharma | [2-doctrine/soul-karma-dharma-and-death/dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md) | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | 1 | 6 | | 1 | 2 | 10 |
| Liberation | [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | | 1 | 2 | | | 1 | 4 |
| Death | [2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md) | [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | | 5 | | | 1 | 6 |
| Consciousness | [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | | 3 | 4 | 2 | 1 | 1 | 11 |
| Meditation | [3-practice/meditation](../content/3-practice/meditation/README.md) | | 1 | | 6 | 3 | | 10 |
| Prayer | [3-practice/prayer](../content/3-practice/prayer.md) | | 1 | | 2 | 2 | | 5 |
| Holy texts | [3-practice/holy-texts](../content/3-practice/holy-texts.md) | | | | 2 | 1 | | 3 |
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
| Seicho-No-Ie | [2-doctrine/enlightened-figures/masaharu-taniguchi](../content/2-doctrine/enlightened-figures/masaharu-taniguchi.md) | | | 1 | 2 | 1 | 1 | 5 |
| Shinsokan | [3-practice/meditation/shinsokan-meditation](../content/3-practice/meditation/shinsokan-meditation.md) | | | | 2 | | | 2 |
| Ho'oponopono | [3-practice/meditation/hooponopono-meditation](../content/3-practice/meditation/hooponopono-meditation.md) | | | | 3 | 1 | | 4 |
| Pantheism | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md) | | | | | | 2 | 2 |
| Socinianism | [5-context/historical-context](../content/5-context/historical-context.md) | | | | | | 2 | 2 |

## Findings

### Open

| Id | Type | Pages | Note |
| -- | ---- | ----- | ---- |
| X01 | conflicting | [4-way-of-life/holistic-wellbeing](../content/4-way-of-life/holistic-wellbeing/README.md), [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md) | The section introduction asks for "a cautious engagement with science and modern medicine"; the page under it is titled "Trust in Science and Modern Medicine". The author decides which stance stands. |
| X02 | conflicting | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md), [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md), [1-foundations/author-note](../content/1-foundations/author-note.md) | Comparative Analysis says UPL "doesn't focus on a singular personal deity"; Unity reflects on "the oneness and absolute sovereignty of God" and the Author Note speaks of "God's infinite love". A reader can take these as two different ideas of God. |
| X03 | conflicting | [5-context/comparative-analysis](../content/5-context/comparative-analysis.md), [2-doctrine/enlightened-figures/buddha](../content/2-doctrine/enlightened-figures/buddha.md) | Comparative Analysis says UPL refrains from "affirming suffering as an inherent characteristic of life"; the Buddha page honours his "insights into the nature of suffering". The two are compatible only if the first is read narrowly. |
| X04 | ambiguous | [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md), [1-foundations/purpose](../content/1-foundations/purpose.md) | Two statements of the mission. Name, Mission, and Vision names compassion, wisdom and enlightenment through unity, ethical living and continuous learning; Purpose says the mission "pivots around" freedom, acceptance, ethical living, love and continuous spiritual growth. |
| X05 | ambiguous | [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md), [3-practice/positive-thinking-gratefulness-and-mindful-action](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/README.md) | The core belief and the practice section carry almost the same title and do not link to each other. A reader or a search engine cannot tell which is the statement and which the elaboration. |
| X06 | ambiguous | [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md), [4-way-of-life/environmental-stewardship](../content/4-way-of-life/environmental-stewardship/README.md) | The core belief and the way-of-life section share a name and do not link to each other. |
| X07 | ambiguous | [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md), [4-way-of-life/environmental-stewardship/principle-of-interconnectedness](../content/4-way-of-life/environmental-stewardship/principle-of-interconnectedness.md) | Two pages are named for interconnectedness. The core belief names it only in its title and speaks of knowledge; the other treats it only for nature. No page states the concept in general. |
| X08 | ambiguous | [3-practice/other-practices](../content/3-practice/other-practices.md), [3-practice](../content/3-practice/README.md) | Other Practices is a general statement about practice, which the part introduction already gives. Its title promises a list it does not contain. |
| X09 | redundant | [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md), [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | The silkworm and cocoon image is given in full on both pages, a result of splitting the paper. |
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

## Pages

| Page | Status | Owns | Also names |
| ---- | ------ | ---- | ---------- |
| [1-foundations](../content/1-foundations/README.md) | current | | Mission and vision, Purpose |
| [1-foundations/abstract](../content/1-foundations/abstract.md) | current | | The name Synphotodosism, Unity, Spiritual evolution and practice, Ethical and moral living, Interconnectedness, Pursuit of knowledge and continuous learning, Community and fellowship, Positive thinking, Gratitude, Mindful action, Quantum physics, The immortal soul, Karma, Dharma, Consciousness |
| [1-foundations/author-note](../content/1-foundations/author-note.md) | current | | Mission and vision, Unity, Community and fellowship, Gratitude, God |
| [1-foundations/core-beliefs](../content/1-foundations/core-beliefs/README.md) | current | | Unity, Spiritual evolution and practice, Ethical and moral living, Family, Fitrah, Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Environmental stewardship, Community and fellowship, Positive thinking, Gratitude, Mindful action |
| [1-foundations/core-beliefs/community-and-social-welfare](../content/1-foundations/core-beliefs/community-and-social-welfare.md) | current | Community and fellowship, Ummah | Environmental stewardship |
| [1-foundations/core-beliefs/compassionate-action](../content/1-foundations/core-beliefs/compassionate-action.md) | current | Compassionate action | Family, Community and fellowship |
| [1-foundations/core-beliefs/environmental-stewardship](../content/1-foundations/core-beliefs/environmental-stewardship.md) | current | Environmental stewardship | God |
| [1-foundations/core-beliefs/ethical-and-moral-living](../content/1-foundations/core-beliefs/ethical-and-moral-living.md) | current | Ethical and moral living, Zakat | Compassionate action, Community and fellowship, Ummah |
| [1-foundations/core-beliefs/inclusive-family-structures-and-fitrah](../content/1-foundations/core-beliefs/inclusive-family-structures-and-fitrah.md) | current | Family, Fitrah | |
| [1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge](../content/1-foundations/core-beliefs/interconnectedness-and-the-pursuit-of-knowledge.md) | current | Interconnectedness, Pursuit of knowledge and continuous learning | |
| [1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action](../content/1-foundations/core-beliefs/positive-thinking-gratefulness-and-mindful-action.md) | current | Positive thinking | Gratitude, Mindful action |
| [1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions](../content/1-foundations/core-beliefs/respect-for-the-wisdom-of-world-traditions.md) | current | Respect for the wisdom of world traditions | Enlightened figures |
| [1-foundations/core-beliefs/spiritual-evolution-and-practice](../content/1-foundations/core-beliefs/spiritual-evolution-and-practice.md) | current | Spiritual evolution and practice | Unity, Community and fellowship, Meditation, Prayer |
| [1-foundations/core-beliefs/unity](../content/1-foundations/core-beliefs/unity.md) | current | Unity | Divine light, God, Consciousness, Tawhid |
| [1-foundations/name-mission-and-vision](../content/1-foundations/name-mission-and-vision.md) | current | The name Synphotodosism, Mission and vision | Purpose, Unity, Ethical and moral living, Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Community and fellowship, Positive thinking, Divine light, The immortal soul |
| [1-foundations/purpose](../content/1-foundations/purpose.md) | current | Purpose | The name Synphotodosism, Mission and vision, Spiritual evolution and practice, Ethical and moral living, Liberation, Consciousness |
| [2-doctrine](../content/2-doctrine/README.md) | current | | Ethical and moral living, Divine light, God, Quantum physics, Enlightened figures, The immortal soul, Karma, Dharma, Death |
| [2-doctrine/enlightened-figures](../content/2-doctrine/enlightened-figures/README.md) | current | Enlightened figures | Unity, Ethical and moral living, Compassionate action, Respect for the wisdom of world traditions, Positive thinking, Divine light, God |
| [2-doctrine/enlightened-figures/buddha](../content/2-doctrine/enlightened-figures/buddha.md) | current | | Spiritual evolution and practice, Ethical and moral living, Compassionate action, Interconnectedness |
| [2-doctrine/enlightened-figures/jesus](../content/2-doctrine/enlightened-figures/jesus.md) | current | | The name Synphotodosism, Compassionate action, Interconnectedness, Community and fellowship, Divine light |
| [2-doctrine/enlightened-figures/masaharu-taniguchi](../content/2-doctrine/enlightened-figures/masaharu-taniguchi.md) | current | Seicho-No-Ie | Unity, Positive thinking, Divine light |
| [2-doctrine/enlightened-figures/muhammad](../content/2-doctrine/enlightened-figures/muhammad.md) | current | Tawhid | Unity, Ethical and moral living, Compassionate action, Pursuit of knowledge and continuous learning, Community and fellowship, God |
| [2-doctrine/enlightened-figures/other-spiritual-leaders](../content/2-doctrine/enlightened-figures/other-spiritual-leaders.md) | current | | Unity, Divine light, God |
| [2-doctrine/ethical-and-moral-development](../content/2-doctrine/ethical-and-moral-development/README.md) | current | | Unity, Spiritual evolution and practice, Ethical and moral living, Respect for the wisdom of world traditions, Community and fellowship, The immortal soul, Dharma, Eightfold Path |
| [2-doctrine/ethical-and-moral-development/diverse-ethical-teachings](../content/2-doctrine/ethical-and-moral-development/diverse-ethical-teachings.md) | current | Eightfold Path | The name Synphotodosism, Spiritual evolution and practice, Ethical and moral living, Compassionate action, Community and fellowship, Dharma, Zakat |
| [2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice](../content/2-doctrine/ethical-and-moral-development/ethical-living-as-spiritual-practice.md) | current | | Spiritual evolution and practice, Ethical and moral living, Compassionate action, Divine light |
| [2-doctrine/ethical-and-moral-development/fabric-of-ethics](../content/2-doctrine/ethical-and-moral-development/fabric-of-ethics.md) | current | | Ethical and moral living, The immortal soul |
| [2-doctrine/god-quantum-physics-and-the-light-of-divinity](../content/2-doctrine/god-quantum-physics-and-the-light-of-divinity.md) | current | Divine light, God, Quantum physics | Interconnectedness, Consciousness, Science and technology, Arts and creativity |
| [2-doctrine/soul-karma-dharma-and-death](../content/2-doctrine/soul-karma-dharma-and-death/README.md) | current | | Unity, The immortal soul, The silkworm and cocoon image, Karma, Dharma, Liberation, Death, Consciousness |
| [2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness](../content/2-doctrine/soul-karma-dharma-and-death/continuum-of-life-and-consciousness.md) | current | Consciousness | The silkworm and cocoon image, Death |
| [2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey](../content/2-doctrine/soul-karma-dharma-and-death/death-as-a-transformative-journey.md) | current | Death | The immortal soul, Consciousness |
| [2-doctrine/soul-karma-dharma-and-death/dharma](../content/2-doctrine/soul-karma-dharma-and-death/dharma.md) | current | Dharma | Purpose, The immortal soul, The silkworm and cocoon image |
| [2-doctrine/soul-karma-dharma-and-death/immortal-soul](../content/2-doctrine/soul-karma-dharma-and-death/immortal-soul.md) | current | The immortal soul, The silkworm and cocoon image | Divine light, Death |
| [2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation](../content/2-doctrine/soul-karma-dharma-and-death/karma-and-dharma-in-liberation.md) | current | Liberation | The immortal soul, The silkworm and cocoon image, Karma, Dharma |
| [2-doctrine/soul-karma-dharma-and-death/karma](../content/2-doctrine/soul-karma-dharma-and-death/karma.md) | current | Karma | Ethical and moral living, The immortal soul, The silkworm and cocoon image |
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
| [3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness](../content/3-practice/positive-thinking-gratefulness-and-mindful-action/positive-thinking-and-gratefulness.md) | current | | Positive thinking, Gratitude, The immortal soul |
| [3-practice/prayer](../content/3-practice/prayer.md) | current | Prayer | Unity, Respect for the wisdom of world traditions, Gratitude |
| [4-way-of-life](../content/4-way-of-life/README.md) | current | | Unity, Family, Pursuit of knowledge and continuous learning, Environmental stewardship, Community and fellowship, Sobriety, Science and technology, Arts and creativity |
| [4-way-of-life/community-and-fellowship](../content/4-way-of-life/community-and-fellowship/README.md) | current | | Spiritual evolution and practice, Interconnectedness, Community and fellowship, Prayer, Seicho-No-Ie, Ho'oponopono |
| [4-way-of-life/community-and-fellowship/community-engagement](../content/4-way-of-life/community-and-fellowship/community-engagement.md) | current | Rituals and celebrations | Family, Environmental stewardship, Community and fellowship, Positive thinking, Mindful action, Karma, Dharma, Meditation, Prayer, Holy texts |
| [4-way-of-life/community-and-fellowship/global-spiritual-network](../content/4-way-of-life/community-and-fellowship/global-spiritual-network.md) | current | | Interconnectedness, Community and fellowship, Meditation, Science and technology |
| [4-way-of-life/community-and-fellowship/role-of-community](../content/4-way-of-life/community-and-fellowship/role-of-community.md) | current | | Unity, Spiritual evolution and practice, Compassionate action, Community and fellowship |
| [4-way-of-life/continuous-learning](../content/4-way-of-life/continuous-learning/README.md) | current | | Spiritual evolution and practice, Pursuit of knowledge and continuous learning, Community and fellowship, Science and technology, Arts and creativity |
| [4-way-of-life/continuous-learning/arts-and-creative-expression](../content/4-way-of-life/continuous-learning/arts-and-creative-expression.md) | current | Arts and creativity | Pursuit of knowledge and continuous learning, Environmental stewardship, Community and fellowship |
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
| [4-way-of-life/holistic-wellbeing/science-and-modern-medicine](../content/4-way-of-life/holistic-wellbeing/science-and-modern-medicine.md) | current | Science and modern medicine | Spiritual evolution and practice, Pursuit of knowledge and continuous learning, Community and fellowship, Science and technology |
| [4-way-of-life/holistic-wellbeing/sobriety](../content/4-way-of-life/holistic-wellbeing/sobriety.md) | current | Sobriety | Environmental stewardship, The immortal soul, Rituals and celebrations |
| [5-context](../content/5-context/README.md) | current | | |
| [5-context/comparative-analysis](../content/5-context/comparative-analysis.md) | current | Pantheism | Spiritual evolution and practice, Ethical and moral living, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Community and fellowship, God, Karma, Dharma, Science and technology |
| [5-context/conclusion](../content/5-context/conclusion.md) | current | | Purpose, Unity, Spiritual evolution and practice, Ethical and moral living, Family, Compassionate action, Interconnectedness, Pursuit of knowledge and continuous learning, Respect for the wisdom of world traditions, Environmental stewardship, Community and fellowship, Positive thinking, Gratitude, Mindful action, Divine light, Quantum physics, Enlightened figures, The immortal soul, Karma, Dharma, Liberation, Sobriety, Science and technology, Arts and creativity |
| [5-context/historical-context](../content/5-context/historical-context.md) | current | Socinianism | Tawhid, Pantheism |
| [5-context/references](../content/5-context/references.md) | current | | Unity, Quantum physics, Death, Consciousness, Seicho-No-Ie, Socinianism |
| [README](../content/README.md) | current | | The name Synphotodosism, Unity, Rituals and celebrations |
