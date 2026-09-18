// Every-page mobile and desktop compatibility gate. Renders every built page in headless
// Chromium at phone, tablet and desktop widths and asserts, per page and per viewport:
//   1. no horizontal overflow (scrollWidth <= clientWidth + 2), at every width, so a mobile
//      fix that breaks the desktop view fails the same gate;
//   2. the viewport meta tag is present;
//   3. the <main> landmark is present;
//   4. on phone widths, touch targets are large enough: header navigation links at least
//      44 CSS px tall, breadcrumb links at least 24 (WCAG 2.2 AA target size). Links inside
//      running text are exempt, as the standard allows.
// Functional checks only, no screenshot comparison. Pages are discovered from the build, so
// new pages are covered with no edit here. Run after `astro build`.
// Adapted from salvador-cloud-site scripts/audit-viewport-overflow.ts (MIT), see
// THIRD-PARTY-NOTICES.md.
import { createServer } from 'node:http';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { extname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const dist = fileURLToPath(new URL('../dist/', import.meta.url));
if (!existsSync(dist)) {
  console.error('check-mobile: site/dist is missing; run the build first');
  process.exit(2);
}

let chromium;
try {
  ({ chromium } = await import('playwright'));
} catch {
  console.error('check-mobile: playwright is not installed; run `npm --prefix site ci`');
  process.exit(2);
}

const VIEWPORTS = [
  { name: 'phone-small', width: 320, height: 568, phone: true },
  { name: 'phone', width: 375, height: 812, phone: true },
  { name: 'tablet', width: 768, height: 1024, phone: false },
  { name: 'desktop', width: 1280, height: 800, phone: false },
];
const OVERFLOW_TOLERANCE = 2;
const TYPES = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png' };

const pages = (function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return walk(path);
    return name === 'index.html' ? [`/${relative(dist, dir)}/`.replace('//', '/')] : [];
  });
})(dist).sort();

// A static server for dist, so the gate depends on nothing but the build.
const server = createServer((req, res) => {
  const path = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  const file = join(dist, path.endsWith('/') ? join(path, 'index.html') : path);
  if (!file.startsWith(dist) || !existsSync(file) || statSync(file).isDirectory()) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'content-type': TYPES[extname(file)] ?? 'application/octet-stream' }).end(readFileSync(file));
});
await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const base = `http://127.0.0.1:${server.address().port}`;

let browser;
try {
  browser = await chromium.launch();
} catch (error) {
  console.error(`check-mobile: Chromium is not available; run \`npx --prefix site playwright install chromium\`\n${error.message.split('\n')[0]}`);
  server.close();
  process.exit(2);
}

const problems = [];
for (const viewport of VIEWPORTS) {
  const context = await browser.newContext({
    viewport: { width: viewport.width, height: viewport.height },
    reducedMotion: 'reduce',
    hasTouch: viewport.phone,
  });
  const page = await context.newPage();
  for (const path of pages) {
    await page.goto(base + path, { waitUntil: 'load' });
    const result = await page.evaluate(() => {
      const root = document.documentElement;
      const sizes = (selector) =>
        [...document.querySelectorAll(selector)].map((a) => {
          const box = a.getBoundingClientRect();
          return { text: a.textContent.trim().slice(0, 30), width: Math.round(box.width), height: Math.round(box.height) };
        });
      // The widest element, to make an overflow report actionable.
      let widest = null;
      if (root.scrollWidth > root.clientWidth) {
        for (const el of document.body.querySelectorAll('*')) {
          const right = el.getBoundingClientRect().right;
          if (!widest || right > widest.right) widest = { right: Math.round(right), tag: el.tagName.toLowerCase(), cls: el.className };
        }
      }
      return {
        scrollWidth: root.scrollWidth,
        clientWidth: root.clientWidth,
        widest,
        viewportMeta: Boolean(document.querySelector('meta[name="viewport"][content*="width=device-width"]')),
        main: Boolean(document.querySelector('main')),
        nav: sizes('header a'),
        crumbs: sizes('.crumbs a'),
      };
    });
    const where = `${path} @ ${viewport.name} (${viewport.width}px)`;
    if (result.scrollWidth > result.clientWidth + OVERFLOW_TOLERANCE) {
      const culprit = result.widest ? `; widest element <${result.widest.tag} class="${result.widest.cls}"> reaches ${result.widest.right}px` : '';
      problems.push(`${where}: horizontal overflow, content is ${result.scrollWidth}px wide${culprit}`);
    }
    if (!result.viewportMeta) problems.push(`${where}: no viewport meta tag`);
    if (!result.main) problems.push(`${where}: no <main> landmark`);
    if (viewport.phone) {
      for (const link of result.nav) if (link.height < 44) problems.push(`${where}: header link "${link.text}" is ${link.height}px tall, needs 44`);
      for (const link of result.crumbs) if (link.height < 24) problems.push(`${where}: breadcrumb link "${link.text}" is ${link.height}px tall, needs 24`);
    }
  }
  await context.close();
}
await browser.close();
server.close();

if (problems.length) {
  const shown = problems.slice(0, 40);
  console.error(shown.join('\n'));
  if (problems.length > shown.length) console.error(`... and ${problems.length - shown.length} more`);
  console.error(`check-mobile: ${problems.length} problem(s) across ${pages.length} pages and ${VIEWPORTS.length} viewports`);
  process.exit(1);
}
console.log(`check-mobile: ${pages.length} pages at ${VIEWPORTS.map((v) => v.width).join(', ')}px: no overflow, viewport and main present, touch targets large enough`);
