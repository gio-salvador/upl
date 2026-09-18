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

const pages = walk(dist).filter((f) => f.endsWith('.html'));
const descriptions = new Map();
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
  need(/"@type":"WebSite"/.test(html), page, 'no WebSite JSON-LD');
  const alternate = attr(html, /<link rel="alternate" type="text\/markdown" href="([^"]+)"/);
  need(alternate && existsSync(join(dist, alternate)), page, 'no markdown alternate, or it was not built');
  if (page !== 'index.html') {
    need(/"@type":"Article"/.test(html), page, 'no Article JSON-LD');
    need(/"@type":"BreadcrumbList"/.test(html), page, 'no BreadcrumbList JSON-LD');
    if (description) descriptions.set(description, [...(descriptions.get(description) ?? []), page]);
  }
}
for (const [, where] of descriptions) need(where.length === 1, where[0], `description duplicated on ${where.slice(1).join(', ')}`);

for (const file of ['robots.txt', 'sitemap-index.xml', 'llms.txt', 'llms-full.txt', 'og-default.png', 'favicon.svg']) {
  need(existsSync(join(dist, file)), file, 'was not built');
}
const llms = existsSync(join(dist, 'llms.txt')) ? readFileSync(join(dist, 'llms.txt'), 'utf8') : '';
const listed = (llms.match(/^\s*- \[/gm) ?? []).length;
need(listed >= pages.length - 2, 'llms.txt', `lists ${listed} pages but the site has ${pages.length - 2} content pages below the home page`);

if (problems.length) {
  console.error(problems.join('\n'));
  console.error(`check-seo: ${problems.length} problem(s) across ${pages.length} pages`);
  process.exit(1);
}
console.log(`check-seo: ${pages.length} pages, all carry title, description, canonical, social image, JSON-LD and a markdown alternate`);
