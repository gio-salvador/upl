import { defineConfig } from 'astro/config';
import { unified } from '@astrojs/markdown-remark';
import sitemap from '@astrojs/sitemap';
import { rewriteContentLinks } from './src/lib/rewrite-links.mjs';

// The canonical text lives in ../content as plain markdown. The site only renders it.
// Fully static output (no adapter, no server code), so it deploys to Cloudflare Pages as is.
// Pages serves folders with a trailing slash, so links use one too and avoid a redirect per click.
// SITE is the public origin, used for canonical URLs, the sitemap and robots.txt.
// Set it in the Cloudflare Pages environment once the address is known.
if (!process.env.SITE && (process.env.CI || process.env.CF_PAGES)) {
  throw new Error('SITE is not set. A CI or Cloudflare build without it would publish localhost URLs.');
}

export default defineConfig({
  site: process.env.SITE ?? 'http://localhost:4321',
  integrations: [sitemap()],
  output: 'static',
  trailingSlash: 'always',
  build: { format: 'directory', inlineStylesheets: 'never' },
  markdown: { processor: unified({ remarkPlugins: [rewriteContentLinks] }) },
});
