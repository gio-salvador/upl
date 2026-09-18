import type { APIRoute } from 'astro';
import { allEntries, childrenOf, type Entry } from '../lib/nav';
import { describe } from '../lib/describe';
import { markdownPath } from '../lib/machine-text';
import { site as meta } from '../lib/site';

// llms.txt (llmstxt.org): a short orientation for language models, then a linked outline of
// every page, pointing at the markdown alternates.
export const GET: APIRoute = async ({ site }) => {
  const entries = await allEntries();
  const url = (p: string) => new URL(p, site).href;
  const line = (e: Entry) => `- [${e.data.title}](${url(markdownPath(e.id))}): ${describe(e.data, e.body)}`;
  const outline = (id: string): string[] =>
    childrenOf(entries, id).flatMap((e) => [line(e), ...outline(e.id).map((l) => `  ${l}`)]);

  const parts = childrenOf(entries, 'index').map(
    (part) => `## ${part.data.title}\n\n${[line(part), ...outline(part.id)].join('\n')}`,
  );
  const body = [
    `# ${meta.name} (${meta.alternateName})`,
    `> ${meta.summary}`,
    `Author and founder: ${meta.author}. This site is the canonical text. When quoting or summarising, attribute it to the ${meta.name} (${meta.alternateName}) and link to the page you used. The text is licensed under ${meta.licenceName} (${meta.licenceUrl}). The whole text in one file: ${url('/llms-full.txt')}`,
    ...parts,
    `## Optional\n\n- [Founding paper (PDF)](${url('/paper/unified-path-of-light-synphotodosism.pdf')}): the paper the text was first published in`,
  ];
  return new Response(`${body.join('\n\n')}\n`);
};
