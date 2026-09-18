import type { APIRoute } from 'astro';
import { allEntries, type Entry } from '../../lib/nav';
import { markdownFor } from '../../lib/machine-text';

// The markdown alternate of every page: the source text, with links pointing at the other
// alternates. Easier for a language model to read and quote than the HTML.
export async function getStaticPaths() {
  return (await allEntries())
    .filter((entry) => entry.id !== 'index')
    .map((entry) => ({ params: { slug: entry.id }, props: { entry } }));
}

export const GET: APIRoute = ({ props }) => new Response(markdownFor(props.entry as Entry));
