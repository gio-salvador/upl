// Text for machines: the markdown alternate of each page, llms.txt and llms-full.txt.
// All three come from the same entries and the same route function as the HTML pages, so
// they cannot drift from the site.
import path from 'node:path';
import { routeFor } from './routes.mjs';
import { childrenOf, type Entry } from './nav';

const CONTENT_MARKER = '/content/';

export const pagePath = (id: string) => (id === 'index' ? '/' : `/${id}/`);
export const markdownPath = (id: string) => `${pagePath(id)}index.md`;

// Rewrites relative .md links so they point at the markdown alternates on the site.
export function markdownFor(entry: Entry): string {
  const file = (entry.filePath ?? '').replaceAll(path.sep, '/');
  const dir = path.posix.dirname(file.split(CONTENT_MARKER).pop() ?? '');
  return (entry.body ?? '').replace(/\]\((?![a-z]+:|#|\/)([^)#\s]+)(#[^)\s]*)?\)/gi, (whole, target, hash = '') => {
    const resolved = path.posix.normalize(path.posix.join(dir, target));
    if (resolved.startsWith('../paper/')) return `](${resolved.slice(2)}${hash})`;
    if (resolved.startsWith('..') || !target.endsWith('.md')) return whole;
    return `](${markdownPath(routeFor(resolved) || 'index')}${hash})`;
  });
}

// Depth-first reading order, following each folder's `order`.
export function readingOrder(entries: Entry[], id = 'index'): Entry[] {
  return childrenOf(entries, id).flatMap((child) => [child, ...readingOrder(entries, child.id)]);
}
