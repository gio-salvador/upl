import type { APIRoute } from 'astro';
import { getEntry } from 'astro:content';
import { allEntries } from '../lib/nav';
import { markdownFor, pagePath, readingOrder } from '../lib/machine-text';
import { site as meta } from '../lib/site';

// The whole text in reading order, one file, each page under its canonical URL.
export const GET: APIRoute = async ({ site }) => {
  const entries = await allEntries();
  const root = (await getEntry('teachings', 'index'))!;
  const pages = [root, ...readingOrder(entries)].map(
    (e) => `<!-- ${new URL(pagePath(e.id), site).href} -->\n\n${markdownFor(e).trim()}`,
  );
  const head = `# ${meta.name} (${meta.alternateName}): full text\n\n> ${meta.summary}\n\nAuthor and founder: ${meta.author}. Licence: ${meta.licenceName} (${meta.licenceUrl}).`;
  return new Response(`${[head, ...pages].join('\n\n---\n\n')}\n`);
};
