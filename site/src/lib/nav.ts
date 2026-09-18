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
