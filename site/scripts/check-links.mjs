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

const htmlFiles = (dir) =>
  readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return htmlFiles(path);
    return name.endsWith('.html') ? [path] : [];
  });

const problems = [];
let checked = 0;
for (const file of htmlFiles(dist)) {
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

if (problems.length) {
  console.error(problems.join('\n'));
  console.error(`check-links: ${problems.length} problem(s) in ${checked} internal links`);
  process.exit(1);
}
console.log(`check-links: ${checked} internal links, all resolve and all page links end in a slash`);
