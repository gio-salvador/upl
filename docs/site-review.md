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

Two rules shape the proposals. The wording of a teaching is the author's (locked decision 2), so
anything touching wording is listed as a question for the author, never as a fix. No client-side
JavaScript (locked decision 4), so every site proposal is plain HTML and CSS.

## What is already good

The reading experience is calm and fast: one column, a serif face, no scripts, a working dark
mode. Every page has a title, description, canonical address, social tags, breadcrumb and
article data, and a markdown alternate. Links, headers, mobile overflow and touch targets are
gated. None of the proposals below asks to undo any of that.

## Site-wide findings, most important first

### S1. Link colour fails contrast in light mode (accessibility, fix first)

Links are `#a8741a` on `#fdfaf3`, a ratio of 3.89 to 1. WCAG AA asks for 4.5 to 1 for body text.
Dark mode passes (9.54 to 1), and so does the muted text in both modes. Every page is affected
because navigation, breadcrumbs and contents lists are all links.

Proposal: darken the light-mode accent to about `#8a5d0f` (roughly 5.6 to 1) and add a contrast
assertion to `site/scripts/check-mobile.mjs` or a small new check, so it cannot regress.

### S2. Leaf pages are dead ends

61 of the 79 content pages have no link in their body at all. The only ways onward are the
breadcrumb and the top navigation. Many of these pages are very short (the ten core beliefs
run from 36 to 63 words), so a reader arrives, reads two sentences, and has to climb back up to
the list to find the next one. The text was written as one continuous paper and reads best in
sequence; the site does not offer that sequence.

Proposal: add "previous" and "next" links at the foot of every content page, following reading
order (the same order `llms-full.txt` already uses), plus an "up" link to the section. This is
generated from `order` front matter in `site/src/lib/nav.ts`, holds no copy of any teaching, and
needs no script.

### S3. The home page does not introduce the religion to a newcomer

The home page is 73 words: a definition, a sentence about the repository ("organised as a
hierarchy", "kept in `paper/`") and a five-item list. The link to the founding paper shows as
the code-styled text `paper/`, which means something on GitHub and nothing on the website. A
first-time visitor is not told what the five parts contain, where to start, or what the ten
principles are.

Proposal, in two steps. First, a structural fix with no new wording: have the site render the
part descriptions that already exist on each part page under the five links, and present the
paper link as "founding paper (PDF)". Second, for the author: consider writing a short
introduction for newcomers and a suggested starting point. That is new connecting text and
belongs in its own pull request.

### S4. Most descriptions are a cut-off first sentence

69 of 80 meta descriptions are the first paragraph cut at 160 characters and ending in "…".
These are what search results, link previews and `llms.txt` show. Where the first sentence is a
fragment carried over from the paper (see W1 below), the description reads badly, for example
"To value the profound impact of enlightened figures…". Two pages fall back to a generic line
(Meditation, References).

Proposal: the author writes a one-sentence `description` in front matter for each page,
starting with the 18 section pages and the ten core beliefs. Front matter is metadata, not
teaching text, so this fits locked decision 3. A gate could then require it.

### S5. Twenty-five titles are longer than search results show

Titles are "page title | Unified Path of Light". 25 of them pass 65 characters and will be cut,
the longest at 94 ("The Integration of Positive Thinking, Gratefulness, and Mindful Action").

Proposal: drop the site-name suffix when the full title would pass 60 characters. This is a
change in `site/src/components/seo/Meta.astro` only; headings are untouched.

### S6. Section pages list titles only

Section pages such as Core Beliefs show a numbered list of titles and nothing else. The
descriptions exist and are already used in `llms.txt`.

Proposal: render each child's description under its link on section pages. This depends on S4,
because cut-off descriptions would look worse here than they do hidden in metadata.

### S7. Navigation and landmarks

- There is no skip link, so keyboard and screen-reader users pass through six header links on
  every page.
- The top navigation does not mark the current part (`aria-current="page"` and a visual cue).
- The breadcrumb is a paragraph. It should be a `nav` with `aria-label="Breadcrumb"` and an
  ordered list, and the header `nav` needs its own label so the two can be told apart.
- On a phone the header takes three rows, about 156 pixels, before any text. Tighter spacing or
  a single scrolling row would give the text more of the first screen. Any change here must
  keep the 44 pixel touch targets.

### S8. The footer carries nothing useful

The footer is the tagline only. There is no link to the founding paper, the source repository
(once public), the licence, `llms.txt`, or a way to report a problem. None of these is reachable
from any page except the paper, and that only from the home page.

Proposal: a short footer row of links. No personal data beyond the author's public name.

### S9. Smaller items

- The 404 page offers only the home link. Listing the five parts would help a lost reader.
- There is no print stylesheet. A text people may want on paper deserves one: hide navigation,
  black on white, show link addresses.
- Long pages (God and quantum physics at 350 words, Conclusion at 344) are dense blocks.
  Slightly more paragraph spacing and a `max-width` nearer 38rem would ease reading. This is
  taste, so it is offered, not urged.
- No site search. With 79 short pages, a full contents page (every page, in order, on one
  screen) does the same job with no script. `llms.txt` already has the data.

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
  Janusz Tazbir (PWN, 1983). The Thích Nhất Hạnh title is "The Heart of the Buddha's Teaching".
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

Words are body words as built. "Dead end" means no onward link in the body (S2). "Cut" means the
description is a truncated first paragraph (S4).

### Home and Foundations

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Home | 73 | Weakest page for its importance. Repository language, `paper/` as link text, no orientation. See S3. |
| Foundations | 42 | Clear one-line introduction; good model for a section page. Would gain from child descriptions (S6). |
| Author Note | 232 | Warm and personal, reads well. "tranquilly" (W2). Signature is a bare last line; could be styled as a signature. Dead end. |
| Abstract | 170 | One dense paragraph. The keywords line is a journal convention that looks odd on a web page; the site could style it smaller, without changing it. Dead end. |
| Name, Mission, and Vision | 289 | Strong page and the best answer to "what does the name mean". The second paragraph under "The name" is about the mission, not the name; a question for the author. Dead end. |
| Purpose | 295 | Reads well, clear argument. Four long paragraphs; benefits most from the spacing change in S9. Dead end. |
| Core Beliefs and Principles | 65 | The most important list on the site shows ten bare titles. First candidate for S6. Description is complete. |
| 1 Unity | 63 | Fragment opening. Islam only (W4). Cut. Dead end. |
| 2 Spiritual Evolution and Practice | 38 | Fragment opening; "It" has no referent. Islam only. Cut. Dead end. |
| 3 Ethical and Moral Living | 53 | Full sentences. Islam only; describes Islam more than the principle. Cut. Dead end. |
| 4 Inclusive Family Structures and Fitrah | 41 | Broken sentence (W2), the most visible defect in the text. Title passes 65 characters. Dead end. |
| 5 Compassionate Action | 39 | Fragment opening. Islam only. Page is two sentences on a full screen; shows why S2 matters. Dead end. |
| 6 Interconnectedness and Pursuit of Knowledge | 37 | One sentence, and its subject is Islam, not the principle. Long title. Dead end. |
| 7 Respect for the Wisdom of World Traditions | 44 | Verb agreement (W2). The one principle about many traditions names only one. Dead end. |
| 8 Environmental Stewardship | 39 | Imperative fragment. Should link to the Way of Life section of the same name; the author could add a "see also" line. Dead end. |
| 9 Community and Social Welfare | 54 | Full sentences. Same "see also" opportunity towards Community and Fellowship. Dead end. |
| 10 Positive Thinking, Gratefulness, Mindful Action | 36 | Imperative fragment. Shares its title with a Practice section; a cross-link would help readers and remove ambiguity. Long title. Dead end. |

### Doctrine

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Doctrine | 58 | Good section introduction, complete description. |
| God, Quantum Physics, and the Light of Divinity | 350 | The central doctrinal page and the longest. Fragment opening becomes the description. See W3 on the observer effect. Would gain from two or three subheadings, which is structure, not wording, if the author agrees. Long title. Dead end. |
| The Role of Enlightened Figures | 96 | Fragment opening (W1). Order of figures is fixed as Jesus, Muhammad, Buddha, Taniguchi; fine, and balanced. |
| Jesus | 57 | Clean, complete sentences. Long title. Dead end. |
| Muhammad | 58 | Clean. Dead end. |
| Buddha | 58 | Clean. Dead end. |
| Masaharu Taniguchi | 82 | Clean, and the fullest of the five, which suits the least-known figure. Long title. Dead end. |
| Other Spiritual Leaders | 69 | First sentence has no verb (W1). Laozi and Guru Nanak share one page; each could earn a page if the author wants to widen the range (decision 8). Dead end. |
| Soul, Karma, Dharma, and Death | 160 | Strong introduction; the silkworm image is the most memorable in the text. Longest title in Doctrine at 88 characters. |
| The Immortal Soul | 130 | Reads well. Repeats the silkworm image from its parent almost word for word, which is a result of the split. Long title. Dead end. |
| Karma | 85 | Clear. Dead end. |
| Dharma | 92 | Clear. Dead end. |
| Karma and Dharma in Liberation | 95 | Clear. Long title (84). Dead end. |
| Death as a Transformative Journey | 90 | Imperative fragment opening (W1). A page people in grief may land on from search; worth the author's extra care. Dead end. |
| The Continuum of Life and Consciousness | 96 | "empirically-based" (W3). Should point to Chalmers in References. Dead end. |
| Ethical and Moral Development | 119 | Opening sentence lacks a verb (W1) and is the description. Balanced across four traditions. Long title. |
| The Fabric of Ethics | 61 | Clean, short. Dead end. |
| Incorporating Diverse Ethical Teachings | 137 | Best-balanced page on the site. Two paragraphs open with Title Case phrases ("Islamic Emphasis on Community and Justice highlights") that were subheadings in the paper; they could become real subheadings. Dead end. |
| Ethical Living as Spiritual Practice | 85 | Clean. Dead end. |

### Practices and Rituals

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Practices and Rituals | 64 | Good introduction. |
| Integration of Positive Thinking, Gratefulness, Mindful Action | 108 | Fragment opening (W1). Longest title on the site (94). |
| Positive Thinking and the Power of Gratefulness | 108 | Reads well. Long title. Dead end. |
| Mindful Action and the Embodiment of Gratitude | 85 | Reads well. Long title. Dead end. |
| Gratitude Affirmations and Contemplative Practices | 147 | Good. "expects adherents to" is used here and on six other pages where "encourages" may be meant; a question for the author. |
| Gratitude for Relationships | 86 | Clear. Describes the practice but gives no example affirmation. A reader who wants to practise has nothing to say aloud. The biggest content gap in this part; for the author. Dead end. |
| Gratitude for Life's Blessings | 96 | Same gap. Dead end. |
| Gratitude for Earth and Environmental Blessings | 98 | Same gap. "from the air… and the raw materials" has "from" without "to". Long title. Dead end. |
| Gratitude for the Gift of Life | 92 | Same gap. Long title (83). Dead end. |
| Adopting Prayers from Various Traditions | 71 | Clear, but names no prayer. One example from each of two or more traditions would make it usable. Dead end. |
| Incorporating Various Forms of Meditation | 19 | The only section page with no introduction, so its description is the generic fallback. Needs one sentence from the author. |
| Buddhist Meditation Practices | 50 | "mindfulness, compassion" appears twice in one sentence. No instruction on how to begin. Dead end. |
| Shinsokan Meditation | 51 | Clear but does not say what the practice involves. Dead end. |
| Ho'oponopono Meditation | 50 | Same. The apostrophe should be the ʻokina (Hoʻoponopono) out of respect for the source (decision 6); the address can stay as it is. Dead end. |
| Engaging with Holy Texts | 96 | One of the clearest statements of the religion's stance. Reads well. Dead end. |
| Other Practices | 66 | Reads as a general statement about practice, not a list of other practices; the title promises more than the page gives. Dead end. |

### Way of Life

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Way of Life | 61 | Good introduction, complete description. |
| The Family Dynamic | 81 | Clear and direct. Long title. |
| Inclusive Familial Structures | 74 | Clear. Dead end. |
| Marriage as a Spiritual Union | 74 | Clear. Dead end. |
| Cooperative Growth and Support | 73 | Fragment opening (W1). Dead end. |
| Divorce as a Respectable Ultimatum | 82 | Compassionate and clear. "Ultimatum" means a final demand; "last resort", the phrase the body uses, may be what the title intends. For the author. Dead end. |
| Community and Fellowship | 115 | Well balanced across five traditions; a model page. |
| The Role of Community in Spiritual Growth | 96 | Reads well. Dead end. |
| Practices of Community Engagement | 176 | Good use of subheadings. Promises gatherings and celebrations but the site says nowhere how to find or join one. Dead end. |
| Building a Global Spiritual Network | 86 | Same: describes virtual gatherings that a reader cannot yet reach. If none exist yet, say nothing on the site; if they do, the footer should link to them. Dead end. |
| Environmental Stewardship and the Sacredness of Nature | 110 | Imperative fragment opening (W1). Mentions "indigenous spiritualities" without naming any; naming them would be more respectful (decision 6). Long title. |
| The Principle of Interconnectedness | 73 | Clean. Dead end. |
| Mindful Interaction with the Environment | 100 | Fragment opening under the first subheading. Dead end. |
| Education and Community Involvement | 71 | Clean. Dead end. |
| The Spiritual Dimension of Environmental Stewardship | 101 | Reads well. Long title. Dead end. |
| Holistic Well-being | 90 | "Prioritise oneself's" (W2). The introduction says "a cautious engagement with science" while the child page is titled "Trust in Science"; the two pull in different directions. Long title (84). |
| Sobriety and the Avoidance of Recreational Drugs | 157 | Two slips (W2). "and, thereafter, the world" is unclear. Alcohol is not mentioned either way, which readers will ask. Long title. Dead end. |
| Trust in Science and Modern Medicine | 165 | Clear and responsible. "offering solutions where traditional methods may fall short" reads as if medicine were the fallback; worth the author's eye given the title. Dead end. |
| Continuous Learning | 94 | List slip (W2); "fundamental" twice in two sentences. Long title. |
| Professional Development | 65 | Imperative opening, but a complete sentence. Dead end. |
| Sciences and Technology | 115 | Both subsections open with fragments (W1). Dead end. |
| Arts and Creative Expression | 128 | Reads well. Dead end. |

### Context and the 404 page

| Page | Words | Assessment |
| ---- | ----- | ---------- |
| Context | 27 | Says "the paper's conclusion", which is repository language on a site that presents itself as the text. Fine otherwise. |
| Historical Context | 58 | One sentence for a page with this title. Names three sources and leaves out most of the traditions the text uses (W4). Thinnest page against its promise. Dead end. |
| Comparative Analysis | 167 | Useful and a likely search landing page. The Buddhism line ("affirming suffering as an inherent characteristic of life") simplifies the First Noble Truth, and the Hinduism line reduces it to caste; both sit uneasily with decision 6 and deserve the author's review. Dead end. |
| Conclusion | 344 | Ten short summary paragraphs, one per theme. Each could link to the section it summarises, which is structure only. Two slips (W2). Dead end. |
| References | 108 | See W3. Generic fallback description. Entries would read better as a proper reference list with authors first, and none is linked. Dead end. |
| 404 | 12 | Works, not indexed. Add the five parts (S9). |

## Proposed order of work

Each line is one pull request. The first five need no decision from the author beyond a yes.

1. Fix light-mode link contrast and gate it (S1).
2. Previous, next and up links on every content page (S2).
3. Skip link, labelled navigation, breadcrumb as a list, current-part marker (S7).
4. Title suffix rule for long titles (S5).
5. Footer links, richer 404, print stylesheet (S8, S9).
6. Home page: part descriptions and a readable paper link (S3, first step).
7. Author writes `description` front matter; then show descriptions on section pages and
   require them in a gate (S4, S6).
8. Author decides on W1 to W4, one wording pull request per part, each called out as a wording
   change, with the doctrine baseline re-recorded by the author where pages are locked.
9. Author considers the content gaps: example affirmations and prayers, how to begin each
   meditation, an introduction for Meditation, a fuller Historical Context, and how to join the
   community.
