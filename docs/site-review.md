# Site review, 18 September 2026

A page-by-page review of the website with proposed improvements. For the author, to decide what
to take forward. No page and no site code has been changed: the branch adds this review and the cross-reference
matrix that came out of it.

## How the review was done

- Built the site from `main` at `99c63b6` with `SITE=https://unifiedpathoflight.com` (80 HTML
  pages: 79 content pages and the 404 page).
- Read all 79 content pages in full, about 8,100 words, and compared the odd sentences with the
  founding paper in `paper/`.
- Measured every built page: title length, description, word count, links in the body.
- Rendered nine page types at 375 and 1280 pixels, light and dark, and looked at each.
- Computed colour contrast from `site/src/styles/global.css`.
- The redesign (pull request 21) merged while the review was under way. The site-wide findings
  below were checked again against `main` at `046f045` and each one says where it stands. The
  page-by-page reading of the text is not affected: the redesign changed no page.

Two rules shape the proposals. The wording of a teaching is the author's (locked decision 2), so
anything touching wording is listed as a question for the author, never as a fix. No client-side
JavaScript (locked decision 4), so every site proposal is plain HTML and CSS.

## What is already good

The reading experience is calm and fast: one column, a serif face, no scripts, a working dark
mode, and since the redesign a hero image, numbered cards for contents lists and a pager. Every
page has a title, description, canonical address, social tags, breadcrumb and article data, and
a markdown alternate. Links, headers, mobile overflow and touch targets are gated.

## Site-wide findings

### Settled by the redesign

- **Leaf pages were dead ends.** 61 of 79 pages had no onward link, and many are under 60 words.
  Every page now ends with previous and next links in reading order.
- **Navigation and landmarks.** There is now a skip link, a marker for the current part, a
  labelled breadcrumb, and on a phone the parts sit on one scrolling row.
- **The footer** now links the five parts and the founding paper.
- **Print rules** exist.
- **Link colour.** The old accent measured 3.89 to 1 on the background, under the 4.5 to 1 that
  WCAG AA asks for. The new accent passes.

### Fixed in pull request 26

- **S1. Nothing held the contrast in place.** The failing colour above shipped without any gate
  noticing. A contrast gate now reads the colour tokens and fails under 4.5 to 1, on the page and
  on cards, in light and dark.
- **S2. Long titles.** 26 titles passed 60 characters once " | Unified Path of Light" was added,
  the longest at 94, so search results cut the page's own words. A long title now drops the site
  name. Headings are untouched.
- **S3. The 404 page** offered only the home link. It now lists the five parts.

### Still open

#### S4. The home page still speaks repository language

The second paragraph says the text is "organised as a hierarchy" and "kept in `paper/`", and the
link to the founding paper shows as the code-styled text `paper/`. That means something on GitHub
and nothing on the website. A first-time visitor is not told what the five parts contain or
where to start. The fix is in `content/README.md`, so it is the author's: a link text such as
"the founding paper (PDF)" works in both places.

#### S5. Most descriptions are a cut-off first sentence

69 of 80 meta descriptions are the first paragraph cut at 160 characters and ending in "…".
These are what search results, link previews and `llms.txt` show. Where the first sentence is a
fragment carried over from the paper (see W1 below), the description reads badly, for example
"To value the profound impact of enlightened figures…". Two pages fall back to a generic line
(Meditation, References).

Proposal: the author writes a one-sentence `description` in front matter for each page,
starting with the 18 section pages and the ten core beliefs. Front matter is metadata, not
teaching text, so this fits locked decision 3. It cannot be done for the author: front matter is
part of the fingerprint that locks the Foundations and Doctrine pages, so adding it needs the
author to record the new baseline.

#### S6. Contents cards show titles only

Section pages such as Core Beliefs show ten numbered cards with a title each. With S5 done, each
card could carry its page's description. It depends on S5, because cut-off descriptions would
look worse on a card than they do hidden in metadata.

#### S7. Smaller items

- The footer has no link to the source repository or the licence. Add them when the repository
  is public.
- No site search. With 79 short pages, a full contents page (every page, in order, on one
  screen) does the same job with no script. `llms.txt` already has the data.
- The breadcrumb is a `nav` of links; an ordered list inside it is the more conventional
  structure for screen readers. Minor.

## Wording questions for the author

None of these has been touched. `docs/conventions.md` says typographical slips from the paper
were corrected, so the first group may simply have been missed. Pages under Foundations and
Doctrine are fingerprint-locked, so each accepted change also needs the author to record it.

### W1. Openings that lost their subject

In the paper these sentences follow a heading and lean on it. As stand-alone pages they open
with a fragment, which is also what search engines and language models quote first.

| Page | Opening |
| ---- | ------- |
| Doctrine: God, Quantum Physics | "To envision the universe as…" |
| Doctrine: Enlightened Figures | "To value the profound impact…" |
| Doctrine: Other Spiritual Leaders | "The teachings of additional figures, such as…" (no verb) |
| Doctrine: Ethical and Moral Development | "Ethical and moral development at the heart of its spiritual practice, asserting…" |
| Doctrine: Death as a Transformative Journey | "View death not as an end…" |
| Practice: Integration of Positive Thinking | "To exert the transformative impact…" |
| Way of Life: Cooperative Growth | "To work on oneself…" |
| Way of Life: Environmental Stewardship | "Demonstrate and perform a profound respect…" |
| Way of Life: Mindful Interaction | "To adopt lifestyles that…" |
| Way of Life: Holistic Well-being | "Prioritise oneself's well-being…" |
| Way of Life: Sciences and Technology | both subsections open with fragments |
| Foundations: six of the ten core beliefs | noun-phrase or imperative openings |

### W2. Likely slips

Status: the author asked for these to be fixed on 18 September 2026. The five in Way of Life and
Context are fixed. The three in Foundations wait for the author, because those pages are locked
by fingerprint and one of them needs the author's own words.

| Page | Text | Note |
| ---- | ---- | ---- |
| Author Note | "increased tranquilly" | "tranquillity" |
| Core belief 4, Fitrah | "towards goodness, inherent's belief system." | words are missing; the same break is in the paper |
| Core belief 7 | "Honour enlightened figures and appreciates" | verb agreement |
| Sobriety | "Sobriety is a virtue, clarity of the mind…" | comma splice |
| Sobriety | "Engage in regular, balanced physical activity supports…" | "Engaging" |
| Continuous Learning | "including professional, sciences, technology, the arts is" | list lacks "and" |
| Holistic Well-being | "oneself's" | "one's" |
| Conclusion | "Soul, karma, and dharma shape… It teaches" | "It" has no referent |

### W3. Accuracy points

- Continuum of Life and Consciousness calls the hard problem of consciousness an
  "empirically-based proposition". It is a philosophical argument (Chalmers, already in the
  references), not an empirical finding.
- God, Quantum Physics: the "observer effect" is presented as showing the role of human
  consciousness in shaping reality. The page does call these "analogies", which is the safe
  reading; physicists would not accept the literal one. Worth a careful look because this page
  is the one sceptical readers will test.
- References: "Socinianism and Its Role in the Culture of 16th to 18th Centuries" is credited to
  Krystyna Łyczywek. Catalogues list it as edited by Lech Szczucki with Zbigniew Ogonowski and
  Janusz Tazbir (PWN, 1983); sources S01 and S02 in the [source register](sources.md). The Thích Nhất Hạnh title is "The Heart of the Buddha's Teaching".
  The Stanford work spells itself "Encyclopedia". "Seicho-No-Ie" is the movement; Taniguchi's
  main work is usually cited as "Truth of Life".
- References gives no years, publishers or links, and no page cites a reference. Fuller
  entries would help credibility with both readers and answer engines.

### W4. Balance between traditions

Already recorded in locked decision 8, confirmed here page by page: all ten core beliefs
illustrate themselves through Islam alone, and Historical Context names Islam, pantheism and
Socinianism but none of Buddhism, Hinduism or Seicho-no-Ie, which the rest of the text leans on.
By contrast Diverse Ethical Teachings, Community and Fellowship, and Enlightened Figures are
well balanced and are good models.

## Overlaps between pages

While reading, every case of ambiguous, redundant or conflicting content across pages was
recorded in the new [cross-reference matrix](cross-reference.md): 3 conflicts, 5 ambiguities and
11 redundancies, 3 of them accepted as intended. The three conflicts need the author: the stance
on science ("cautious engagement" against "trust"), the idea of God in Comparative Analysis
against Unity and the Author Note, and the line on suffering against the Buddha page. One
redundancy was found by the gate's wording check, not by reading, which is the case for keeping
it. No page is deprecated today; the status exists for when one is.

## Page by page

Words are body words as built. "Cut" means the
description is a truncated first paragraph (S5).

### Home and Foundations

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Home | 73 | Weakest text for its importance, though the redesign gave it a hero and cards. Repository language, `paper/` as link text, no orientation. See S4. |
| Foundations | 42 | Clear one-line introduction; good model for a section page. Would gain from descriptions on its cards (S6). |
| Author Note | 232 | Warm and personal, reads well. "tranquilly" (W2). Signature is a bare last line; could be styled as a signature. |
| Abstract | 170 | One dense paragraph. The keywords line is a journal convention that looks odd on a web page; the site could style it smaller, without changing it. |
| Name, Mission, and Vision | 289 | Strong page and the best answer to "what does the name mean". The second paragraph under "The name" is about the mission, not the name; a question for the author. |
| Purpose | 295 | Reads well, clear argument. Four long paragraphs. |
| Core Beliefs and Principles | 65 | The most important list on the site shows ten bare titles. First candidate for S6. Description is complete. |
| 1 Unity | 63 | Fragment opening. Islam only (W4). Cut. |
| 2 Spiritual Evolution and Practice | 38 | Fragment opening; "It" has no referent. Islam only. Cut. |
| 3 Ethical and Moral Living | 53 | Full sentences. Islam only; describes Islam more than the principle. Cut. |
| 4 Inclusive Family Structures and Fitrah | 41 | Broken sentence (W2), the most visible defect in the text. |
| 5 Compassionate Action | 39 | Fragment opening. Islam only. Two sentences on a full screen; the pager now carries the reader on. |
| 6 Interconnectedness and Pursuit of Knowledge | 37 | One sentence, and its subject is Islam, not the principle. |
| 7 Respect for the Wisdom of World Traditions | 44 | Verb agreement (W2). The one principle about many traditions names only one. |
| 8 Environmental Stewardship | 39 | Imperative fragment. Should link to the Way of Life section of the same name; the author could add a "see also" line. |
| 9 Community and Social Welfare | 54 | Full sentences. Same "see also" opportunity towards Community and Fellowship. |
| 10 Positive Thinking, Gratefulness, Mindful Action | 36 | Imperative fragment. Shares its title with a Practice section; a cross-link would help readers and remove ambiguity. |

### Doctrine

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Doctrine | 58 | Good section introduction, complete description. |
| God, Quantum Physics, and the Light of Divinity | 350 | The central doctrinal page and the longest. Fragment opening becomes the description. See W3 on the observer effect. Would gain from two or three subheadings, which is structure, not wording, if the author agrees. |
| The Role of Enlightened Figures | 96 | Fragment opening (W1). Order of figures is fixed as Jesus, Muhammad, Buddha, Taniguchi; fine, and balanced. |
| Jesus | 57 | Clean, complete sentences. |
| Muhammad | 58 | Clean. |
| Buddha | 58 | Clean. |
| Masaharu Taniguchi | 82 | Clean, and the fullest of the five, which suits the least-known figure. |
| Other Spiritual Leaders | 69 | First sentence has no verb (W1). Laozi and Guru Nanak share one page; each could earn a page if the author wants to widen the range (decision 8). |
| Soul, Karma, Dharma, and Death | 160 | Strong introduction; the silkworm image is the most memorable in the text. |
| The Immortal Soul | 130 | Reads well. Repeats the silkworm image from its parent almost word for word, which is a result of the split. |
| Karma | 85 | Clear. |
| Dharma | 92 | Clear. |
| Karma and Dharma in Liberation | 95 | Clear. |
| Death as a Transformative Journey | 90 | Imperative fragment opening (W1). A page people in grief may land on from search; worth the author's extra care. |
| The Continuum of Life and Consciousness | 96 | "empirically-based" (W3). Should point to Chalmers in References. |
| Ethical and Moral Development | 119 | Opening sentence lacks a verb (W1) and is the description. Balanced across four traditions. |
| The Fabric of Ethics | 61 | Clean, short. |
| Incorporating Diverse Ethical Teachings | 137 | Best-balanced page on the site. Two paragraphs open with Title Case phrases ("Islamic Emphasis on Community and Justice highlights") that were subheadings in the paper; they could become real subheadings. |
| Ethical Living as Spiritual Practice | 85 | Clean. |

### Practices and Rituals

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Practices and Rituals | 64 | Good introduction. |
| Integration of Positive Thinking, Gratefulness, Mindful Action | 108 | Fragment opening (W1). |
| Positive Thinking and the Power of Gratefulness | 108 | Reads well. |
| Mindful Action and the Embodiment of Gratitude | 85 | Reads well. |
| Gratitude Affirmations and Contemplative Practices | 147 | Good. "expects adherents to" is used here and on six other pages where "encourages" may be meant; a question for the author. |
| Gratitude for Relationships | 86 | Clear. Describes the practice but gives no example affirmation. A reader who wants to practise has nothing to say aloud. The biggest content gap in this part; for the author. |
| Gratitude for Life's Blessings | 96 | Same gap. |
| Gratitude for Earth and Environmental Blessings | 98 | Same gap. "from the air… and the raw materials" has "from" without "to". |
| Gratitude for the Gift of Life | 92 | Same gap. |
| Adopting Prayers from Various Traditions | 71 | Clear, but names no prayer. One example from each of two or more traditions would make it usable. |
| Incorporating Various Forms of Meditation | 19 | The only section page with no introduction, so its description is the generic fallback. Needs one sentence from the author. |
| Buddhist Meditation Practices | 50 | "mindfulness, compassion" appears twice in one sentence. No instruction on how to begin. |
| Shinsokan Meditation | 51 | Clear but does not say what the practice involves. |
| Ho'oponopono Meditation | 50 | Same. The apostrophe should be the ʻokina (Hoʻoponopono) out of respect for the source (decision 6); the address can stay as it is. |
| Engaging with Holy Texts | 96 | One of the clearest statements of the religion's stance. Reads well. |
| Other Practices | 66 | Reads as a general statement about practice, not a list of other practices; the title promises more than the page gives. |

### Way of Life

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Way of Life | 61 | Good introduction, complete description. |
| The Family Dynamic | 81 | Clear and direct. |
| Inclusive Familial Structures | 74 | Clear. |
| Marriage as a Spiritual Union | 74 | Clear. |
| Cooperative Growth and Support | 73 | Fragment opening (W1). |
| Divorce as a Respectable Ultimatum | 82 | Compassionate and clear. "Ultimatum" means a final demand; "last resort", the phrase the body uses, may be what the title intends. For the author. |
| Community and Fellowship | 115 | Well balanced across five traditions; a model page. |
| The Role of Community in Spiritual Growth | 96 | Reads well. |
| Practices of Community Engagement | 176 | Good use of subheadings. Promises gatherings and celebrations but the site says nowhere how to find or join one. |
| Building a Global Spiritual Network | 86 | Same: describes virtual gatherings that a reader cannot yet reach. If none exist yet, say nothing on the site; if they do, the footer should link to them. |
| Environmental Stewardship and the Sacredness of Nature | 110 | Imperative fragment opening (W1). Mentions "indigenous spiritualities" without naming any; naming them would be more respectful (decision 6). |
| The Principle of Interconnectedness | 73 | Clean. |
| Mindful Interaction with the Environment | 100 | Fragment opening under the first subheading. |
| Education and Community Involvement | 71 | Clean. |
| The Spiritual Dimension of Environmental Stewardship | 101 | Reads well. |
| Holistic Well-being | 90 | "Prioritise oneself's" (W2). The introduction says "a cautious engagement with science" while the child page is titled "Trust in Science"; the two pull in different directions. |
| Sobriety and the Avoidance of Recreational Drugs | 157 | Two slips (W2). "and, thereafter, the world" is unclear. Alcohol is not mentioned either way, which readers will ask. |
| Trust in Science and Modern Medicine | 165 | Clear and responsible. "offering solutions where traditional methods may fall short" reads as if medicine were the fallback; worth the author's eye given the title. |
| Continuous Learning | 94 | List slip (W2); "fundamental" twice in two sentences. |
| Professional Development | 65 | Imperative opening, but a complete sentence. |
| Sciences and Technology | 115 | Both subsections open with fragments (W1). |
| Arts and Creative Expression | 128 | Reads well. |

### Context and the 404 page

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Context | 27 | Says "the paper's conclusion", which is repository language on a site that presents itself as the text. Fine otherwise. |
| Historical Context | 58 | One sentence for a page with this title. Names three sources and leaves out most of the traditions the text uses (W4). Thinnest page against its promise. |
| Comparative Analysis | 167 | Useful and a likely search landing page. The Buddhism line ("affirming suffering as an inherent characteristic of life") simplifies the First Noble Truth, and the Hinduism line reduces it to caste; both sit uneasily with decision 6 and deserve the author's review. |
| Conclusion | 344 | Ten short summary paragraphs, one per theme. Each could link to the section it summarises, which is structure only. Two slips (W2). |
| References | 108 | See W3. Generic fallback description. Entries would read better as a proper reference list with authors first, and none is linked. |
| 404 | 12 | Works, not indexed. Lists the five parts as of pull request 26. |

## Proposed order of work

1. Done: pull request 26 (contrast gate, long titles, 404).
2. Author fixes the home page link text and second paragraph (S4).
3. Author writes `description` front matter and records the baseline; then descriptions go on
   the contents cards and a gate requires them (S5, S6).
4. Author decides on W1 to W4, one wording pull request per part, each called out as a wording
   change, with the doctrine baseline recorded again by the author where pages are locked.
5. Author decides the three conflicts in the [cross-reference matrix](cross-reference.md) (X01
   to X03) and the open ambiguities.
6. Author considers the content gaps: example affirmations and prayers, how to begin each
   meditation, an introduction for Meditation, a fuller Historical Context, and how to join the
   community.
