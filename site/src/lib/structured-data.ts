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
