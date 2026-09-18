import type { APIRoute } from 'astro';
import { getEntry } from 'astro:content';
import { markdownFor } from '../lib/machine-text';

export const GET: APIRoute = async () => new Response(markdownFor((await getEntry('teachings', 'index'))!));
