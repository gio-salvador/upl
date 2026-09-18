// Astro caches rendered markdown in a data store and does not notice when the link rewriter
// changes, so stale pages can keep old links. The content is small; start every run clean.
import { rmSync } from 'node:fs';

for (const file of ['../.astro/data-store.json', '../node_modules/.astro/data-store.json']) {
  rmSync(new URL(file, import.meta.url), { force: true });
}
