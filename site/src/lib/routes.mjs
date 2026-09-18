// Maps a path inside content/ to a site route:
// "1-foundations/core-beliefs/unity.md" -> "foundations/core-beliefs/unity"
// "1-foundations/README.md" -> "foundations", "README.md" -> ""
export function routeFor(contentPath) {
  return contentPath
    .replace(/\.md$/, '')
    .split('/')
    .filter((part) => part !== 'README')
    .map((part) => part.replace(/^\d+-/, ''))
    .join('/');
}
