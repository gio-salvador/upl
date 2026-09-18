// Astro caches rendered markdown in a data store and does not notice when the link rewriter
// changes, so stale pages can keep old links. The content is small; start every run clean.
// Dev and build keep separate stores, and each run clears only its own: a build must never
// pull the store out from under a running dev server.
//   node scripts/clear-content-cache.mjs dev|build
import { rmSync } from 'node:fs';

const stores = { dev: '../.astro/data-store.json', build: '../node_modules/.astro/data-store.json' };
const store = stores[process.argv[2]];
if (!store) {
  console.error('usage: clear-content-cache.mjs dev|build');
  process.exit(2);
}
rmSync(new URL(store, import.meta.url), { force: true });
