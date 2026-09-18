// Link gate for the built site: every internal link must resolve to a built file, and every
// page link must end in a slash (Cloudflare Pages serves folders that way, and the dev server
// returns 404 without it). Run after `astro build`.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const dist = fileURLToPath(new URL('../dist/', import.meta.url));
if (!existsSync(dist)) {
  console.error('check-links: site/dist is missing; run the build first');
  process.exit(2);
}

const filesWith = (dir, test) =>
  readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return filesWith(path, test);
    return test(name) ? [path] : [];
  });

const problems = [];
let checked = 0;
for (const file of filesWith(dist, (name) => name.endsWith('.html'))) {
  const html = readFileSync(file, 'utf8');
  for (const [, href] of html.matchAll(/href="([^"]+)"/g)) {
    if (!href.startsWith('/') || href.startsWith('//')) continue;
    checked += 1;
    const path = decodeURIComponent(href.split('#')[0].split('?')[0]);
    const isFile = /\.[a-z0-9]+$/i.test(path);
    const page = relative(dist, file);
    if (!isFile && !path.endsWith('/')) problems.push(`${page}: ${href} has no trailing slash`);
    const target = join(dist, isFile ? path : join(path, 'index.html'));
    if (!existsSync(target)) problems.push(`${page}: ${href} does not resolve to a built file`);
  }
}

// The machine-facing files (markdown alternates, llms.txt, llms-full.txt) link with markdown
// syntax, root-relative or absolute on the site's own origin.
const origin = /^https?:\/\/[^/]+/;
for (const file of filesWith(dist, (name) => name.endsWith('.md') || /^llms.*\.txt$/.test(name))) {
  const text = readFileSync(file, 'utf8');
  for (const [, raw] of text.matchAll(/\]\(([^)\s]+)\)/g)) {
    const href = raw.replace(origin, '');
    if (!href.startsWith('/')) {
      if (!/^[a-z]+:/i.test(raw) && !raw.startsWith('#')) problems.push(`${relative(dist, file)}: ${raw} is a relative link and will not resolve`);
      continue;
    }
    checked += 1;
    const path = decodeURIComponent(href.split('#')[0]);
    if (!existsSync(join(dist, path.endsWith('/') ? join(path, 'index.html') : path))) {
      problems.push(`${relative(dist, file)}: ${raw} does not resolve to a built file`);
    }
  }
}

if (problems.length) {
  console.error(problems.join('\n'));
  console.error(`check-links: ${problems.length} problem(s) in ${checked} internal links`);
  process.exit(1);
}
console.log(`check-links: ${checked} internal links, all resolve and all page links end in a slash`);
