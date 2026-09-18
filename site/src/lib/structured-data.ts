// Schema.org JSON-LD blocks. Adapted from salvador-cloud-site (MIT), see
// THIRD-PARTY-NOTICES.md.
import { site } from './site';

export interface Crumb { label: string; href: string }

export function websiteSchema(origin: URL): Record<string, unknown> {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: site.name,
    alternateName: site.alternateName,
    url: origin.href,
    inLanguage: 'en-GB',
    author: { '@type': 'Person', name: site.author },
    license: site.licenceUrl,
  };
}

const author = { '@type': 'Person', name: site.author };

// One per content page. No dates are emitted: the text carries none, and an invented
// date is worse than a missing one.
export function articleSchema(origin: URL, page: { title: string; description: string; href: string }): Record<string, unknown> {
  const url = new URL(page.href, origin).href;
  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: page.title,
    description: page.description,
    url,
    mainEntityOfPage: url,
    inLanguage: 'en-GB',
    author,
    publisher: author,
    license: site.licenceUrl,
    image: new URL(site.ogImage, origin).href,
    isPartOf: { '@type': 'WebSite', name: site.name, url: origin.href },
    about: { '@type': 'Thing', name: `${site.name} (${site.alternateName})` },
    encoding: { '@type': 'MediaObject', encodingFormat: 'text/markdown', contentUrl: new URL(`${page.href}index.md`, origin).href },
  };
}

// The founding paper, described on the home page.
export function paperSchema(origin: URL): Record<string, unknown> {
  return {
    '@context': 'https://schema.org',
    '@type': 'ScholarlyArticle',
    name: `${site.name} (${site.alternateName})`,
    author,
    license: site.licenceUrl,
    inLanguage: 'en-GB',
    encodingFormat: 'application/pdf',
    url: new URL(site.paperPath, origin).href,
  };
}

export function breadcrumbListSchema(origin: URL, crumbs: Crumb[]): Record<string, unknown> {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: crumbs.map((crumb, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: crumb.label,
      item: new URL(crumb.href, origin).href,
    })),
  };
}
