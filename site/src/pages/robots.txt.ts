import type { APIRoute } from 'astro';

// Built to a static robots.txt. The sitemap line needs the absolute origin.
export const GET: APIRoute = ({ site }) =>
  new Response(`User-agent: *\nAllow: /\n\nSitemap: ${new URL('sitemap-index.xml', site).href}\n`);
