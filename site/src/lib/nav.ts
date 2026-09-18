import { getCollection, type CollectionEntry } from 'astro:content';

export type Entry = CollectionEntry<'teachings'>;

const parentOf = (id: string) => (id.includes('/') ? id.slice(0, id.lastIndexOf('/')) : 'index');

export async function allEntries(): Promise<Entry[]> {
  return getCollection('teachings');
}

export function childrenOf(entries: Entry[], id: string): Entry[] {
  return entries
    .filter((e) => e.id !== 'index' && parentOf(e.id) === id)
    .sort((a, b) => a.data.order - b.data.order);
}

export function trail(entries: Entry[], id: string): Entry[] {
  const parts = id.split('/');
  return parts
    .slice(0, -1)
    .map((_, i) => entries.find((e) => e.id === parts.slice(0, i + 1).join('/')))
    .filter((e): e is Entry => Boolean(e));
}

/** Every page in reading order: each section is followed by its own pages, depth first. */
export function readingOrder(entries: Entry[], id = 'index'): Entry[] {
  return childrenOf(entries, id).flatMap((child) => [child, ...readingOrder(entries, child.id)]);
}

/** The pages before and after `id` in reading order, for the pager at the foot of a page. */
export function neighbours(entries: Entry[], id: string): { previous?: Entry; next?: Entry } {
  const order = readingOrder(entries);
  const at = order.findIndex((e) => e.id === id);
  return { previous: order[at - 1], next: order[at + 1] };
}
