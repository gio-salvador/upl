import type { APIRoute } from 'astro';

// Built to a static robots.txt. Everything is open to everyone. The AI crawlers are named
// on purpose: the text exists to be read and cited, and a named rule is an unambiguous yes
// (plan decision D5). To withdraw that, change Allow to Disallow for the group below.
const AI_CRAWLERS = [
  'GPTBot', 'OAI-SearchBot', 'ChatGPT-User',
  'ClaudeBot', 'Claude-User', 'Claude-SearchBot',
  'PerplexityBot', 'Perplexity-User',
  'Google-Extended', 'Applebot-Extended', 'Amazonbot', 'Meta-ExternalAgent',
  'DuckAssistBot', 'MistralAI-User', 'CCBot',
];

export const GET: APIRoute = ({ site }) =>
  new Response(
    [
      'User-agent: *\nAllow: /',
      `${AI_CRAWLERS.map((bot) => `User-agent: ${bot}`).join('\n')}\nAllow: /`,
      `Sitemap: ${new URL('sitemap-index.xml', site).href}`,
    ].join('\n\n') + '\n',
  );
