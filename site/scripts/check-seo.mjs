// SEO and machine-readability gate for the built site. Checks structure and metadata only;
// it never judges the wording of a teaching. Run after `astro build`.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const dist = fileURLToPath(new URL('../dist/', import.meta.url));
if (!existsSync(dist)) {
  console.error('check-seo: site/dist is missing; run the build first');
  process.exit(2);
}

const walk = (dir) =>
  readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    return statSync(path).isDirectory() ? walk(path) : [path];
  });

const problems = [];
const need = (ok, page, message) => ok || problems.push(`${page}: ${message}`);
const attr = (html, pattern) => html.match(pattern)?.[1];

// Text as a reader sees it, so an HTML heading can be compared with its markdown twin.
const plain = (text) =>
  text
    .replace(/<[^>]+>/g, '')
    .replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"')
    .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(Number(n)))
    .replace(/&#x([0-9a-f]+);/gi, (_, n) => String.fromCodePoint(parseInt(n, 16)))
    .replace(/[\u2018\u2019]/g, "'").replace(/[\u201c\u201d]/g, '"')
    .replace(/\s+/g, ' ')
    .trim();
const read = (file) => (existsSync(join(dist, file)) ? readFileSync(join(dist, file), 'utf8') : '');
const jsonLd = (html) =>
  [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].flatMap((block) => {
    try { return [JSON.parse(block[1])]; } catch { return []; }
  });

const pages = walk(dist).filter((f) => f.endsWith('.html'));
const descriptions = new Map();
const titles = new Map();
const canonicals = new Map();
const alternates = new Set();
const origins = new Set();
for (const file of pages) {
  const page = relative(dist, file);
  const html = readFileSync(file, 'utf8');
  const is404 = page === '404.html';

  need(/<html lang="[a-z-]+"/i.test(html), page, 'no lang attribute');
  need((html.match(/<title>[^<]+<\/title>/g) ?? []).length === 1, page, 'needs exactly one non-empty title');
  need((html.match(/<h1[\s>]/g) ?? []).length === 1, page, 'needs exactly one h1');

  const description = attr(html, /<meta name="description" content="([^"]*)"/);
  need(description && description.length >= 50 && description.length <= 200, page, `description must be 50 to 200 characters, got ${description?.length ?? 0}`);

  for (const block of html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)) {
    try { JSON.parse(block[1]); } catch { problems.push(`${page}: JSON-LD does not parse`); }
  }
  if (is404) {
    need(/<meta name="robots" content="noindex/.test(html), page, 'the 404 page must be noindex');
    continue;
  }

  need(/<link rel="canonical" href="https?:\/\/[^"]+\/"/.test(html), page, 'no canonical URL ending in a slash');
  need(/<meta property="og:image" content="https?:\/\//.test(html), page, 'no absolute og:image');

  // Indexable, and the address every signal agrees on.
  need(!/<meta name="robots" content="[^"]*noindex/.test(html), page, 'a content page must not be noindex');
  const canonical = attr(html, /<link rel="canonical" href="([^"]+)"/);
  if (canonical) {
    const url = new URL(canonical);
    origins.add(url.origin);
    canonicals.set(canonical, page);
    const expected = `/${page.replace(/index\.html$/, '')}`;
    need(url.pathname === expected, page, `canonical path is ${url.pathname}, expected ${expected}`);
    need(attr(html, /<meta property="og:url" content="([^"]+)"/) === canonical, page, 'og:url differs from the canonical URL');
  }
  for (const tag of ['og:title', 'og:description', 'og:type', 'og:site_name', 'og:locale']) {
    need(new RegExp(`<meta property="${tag}" content="[^"]+"`).test(html), page, `no ${tag}`);
  }
  for (const tag of ['twitter:card', 'twitter:title', 'twitter:description', 'twitter:image']) {
    need(new RegExp(`<meta name="${tag}" content="[^"]+"`).test(html), page, `no ${tag}`);
  }
  need(/<meta name="viewport" content="[^"]*width=device-width/.test(html), page, 'no responsive viewport');
  const title = attr(html, /<title>([^<]+)<\/title>/);
  if (title) titles.set(title, [...(titles.get(title) ?? []), page]);
  need(/"@type":"WebSite"/.test(html), page, 'no WebSite JSON-LD');
  const alternate = attr(html, /<link rel="alternate" type="text\/markdown" href="([^"]+)"/);
  need(alternate && existsSync(join(dist, alternate)), page, 'no markdown alternate, or it was not built');
  if (alternate && existsSync(join(dist, alternate))) {
    alternates.add(alternate);
    // The markdown twin is the same page: it opens with the same heading and has a body.
    const markdown = read(alternate);
    const h1 = plain(attr(html, /<h1[^>]*>([\s\S]*?)<\/h1>/) ?? '');
    const heading = plain(markdown.match(/^# (.+)$/m)?.[1] ?? '');
    need(heading && heading === h1, page, `markdown alternate opens with "${heading}", the page heading is "${h1}"`);
    need(markdown.trim().split('\n').length > 1 || page === 'index.html', page, 'markdown alternate has a heading and nothing else');
  }
  if (page !== 'index.html') {
    need(/"@type":"Article"/.test(html), page, 'no Article JSON-LD');
    need(/"@type":"BreadcrumbList"/.test(html), page, 'no BreadcrumbList JSON-LD');
    const blocks = jsonLd(html);
    const article = blocks.find((b) => b['@type'] === 'Article');
    if (article) {
      for (const key of ['headline', 'description', 'author', 'inLanguage', 'isPartOf', 'image']) {
        need(article[key], page, `Article JSON-LD has no ${key}`);
      }
      need(article.url === canonical && article.mainEntityOfPage === canonical, page, 'Article JSON-LD url differs from the canonical URL');
    }
    const crumbs = blocks.find((b) => b['@type'] === 'BreadcrumbList')?.itemListElement ?? [];
    need(crumbs.length >= 2 && crumbs.every((c, i) => c.position === i + 1 && c.name && c.item), page, 'BreadcrumbList is not a numbered trail of named links');
    need(crumbs.at(-1)?.item === canonical, page, 'BreadcrumbList does not end at this page');
  } else {
    const paper = jsonLd(html).find((b) => b['@type'] === 'ScholarlyArticle');
    need(paper?.url && existsSync(join(dist, new URL(paper.url).pathname)), page, 'the home page does not describe the founding paper, or the paper was not built');
    if (description) descriptions.set(description, [...(descriptions.get(description) ?? []), page]);
  }
}
for (const [, where] of descriptions) need(where.length === 1, where[0], `description duplicated on ${where.slice(1).join(', ')}`);

for (const file of ['robots.txt', 'sitemap-index.xml', 'llms.txt', 'llms-full.txt', 'og-default.png', 'favicon.svg']) {
  need(existsSync(join(dist, file)), file, 'was not built');
}
for (const [title, where] of titles) need(where.length === 1, where[0], `title "${title}" duplicated on ${where.slice(1).join(', ')}`);
need(origins.size === 1, 'site', `pages name more than one origin: ${[...origins].join(', ')}`);
const [origin] = origins;

// The sitemap lists every indexable page and nothing else.
const sitemapIndex = read('sitemap-index.xml');
const sitemapUrls = new Set(
  [...sitemapIndex.matchAll(/<loc>([^<]+)<\/loc>/g)].flatMap((m) =>
    [...read(new URL(m[1]).pathname.slice(1)).matchAll(/<loc>([^<]+)<\/loc>/g)].map((u) => u[1])),
);
for (const [canonical, page] of canonicals) need(sitemapUrls.has(canonical), page, 'is missing from the sitemap');
for (const url of sitemapUrls) need(canonicals.has(url), 'sitemap', `lists ${url}, which is not the canonical URL of any page`);

// robots.txt: open to every crawler, names the AI crawlers, and points at the sitemap.
const robots = read('robots.txt');
const robotsLines = robots.split('\n').map((line) => line.trim());
need(robotsLines.includes('User-agent: *'), 'robots.txt', 'has no rule for every crawler');
need(!robotsLines.some((line) => /^Disallow:\s*\/\s*$/i.test(line)), 'robots.txt', 'shuts a crawler out of the whole site');
need(robotsLines.includes(`Sitemap: ${origin}/sitemap-index.xml`), 'robots.txt', `does not name the sitemap at ${origin}/sitemap-index.xml`);
for (const bot of ['GPTBot', 'OAI-SearchBot', 'ClaudeBot', 'PerplexityBot', 'Google-Extended', 'Applebot-Extended', 'CCBot']) {
  need(robotsLines.includes(`User-agent: ${bot}`), 'robots.txt', `does not name ${bot}`);
}

// The headers keep the markdown twins out of the index and the pages in it.
const headers = existsSync(join(dist, '_headers')) ? readFileSync(join(dist, '_headers'), 'utf8') : '';
need(/^\/\*\.md\n(?:[ \t]+.*\n)*?[ \t]+X-Robots-Tag: noindex/m.test(headers), '_headers', 'the markdown alternates must be served noindex, so they do not compete with the pages');
need(!/^\/\*\n(?:[ \t]+.*\n)*?[ \t]+X-Robots-Tag:[^\n]*noindex/m.test(headers), '_headers', 'the whole site is served noindex');

const llms = read('llms.txt');
// llms.txt follows the llmstxt.org shape, and links every markdown twin, each of which exists.
need(/^# .+\n+> .+/.test(llms), 'llms.txt', 'must open with an H1 and a blockquote summary');
const llmsLinks = new Set([...llms.matchAll(/^\s*- \[[^\]]+\]\(([^)]+)\)/gm)].map((m) => new URL(m[1], origin).pathname));
for (const link of llmsLinks) need(existsSync(join(dist, link)), 'llms.txt', `links ${link}, which was not built`);
for (const alternate of alternates) need(alternate === '/index.md' || llmsLinks.has(alternate), 'llms.txt', `does not link ${alternate}`);
need(llms.includes(`${origin}/llms-full.txt`), 'llms.txt', 'does not point at llms-full.txt');

// llms-full.txt carries every page.
const full = read('llms-full.txt');
const fullHeadings = new Set([...full.matchAll(/^#{1,6} (.+)$/gm)].map((m) => plain(m[1])));
for (const alternate of alternates) {
  const heading = plain(read(alternate).match(/^# (.+)$/m)?.[1] ?? '');
  need(alternate === '/index.md' || fullHeadings.has(heading), 'llms-full.txt', `does not carry "${heading}"`);
}
const listed = (llms.match(/^\s*- \[/gm) ?? []).length;
need(listed >= pages.length - 2, 'llms.txt', `lists ${listed} pages but the site has ${pages.length - 2} content pages below the home page`);

if (problems.length) {
  console.error(problems.join('\n'));
  console.error(`check-seo: ${problems.length} problem(s) across ${pages.length} pages`);
  process.exit(1);
}
console.log(`check-seo: ${pages.length} pages, all indexable with matching canonical, sitemap, social tags, JSON-LD and markdown alternate; robots.txt, llms.txt and llms-full.txt are complete`);
