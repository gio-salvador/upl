import fs from 'node:fs';
import path from 'node:path';

const CONTENT_MARKER = `${path.sep}content${path.sep}`;
const cache = new Map();

// The `description` front matter of a content file, or '' if it has none.
function descriptionOf(file) {
  if (!cache.has(file)) {
    let found = '';
    try {
      const head = fs.readFileSync(file, 'utf8').match(/^---\n([\s\S]*?)\n---/);
      const line = head?.[1].match(/^description:\s*(.+)$/m);
      if (line) found = JSON.parse(line[1].trim().startsWith('"') ? line[1].trim() : JSON.stringify(line[1].trim()));
    } catch { /* an unreadable target simply gets no description */ }
    cache.set(file, found);
  }
  return cache.get(file);
}

const soleLink = (item) =>
  item.children.length === 1 && item.children[0].type === 'paragraph' &&
  item.children[0].children.length === 1 && item.children[0].children[0].type === 'link'
    ? item.children[0].children[0] : null;

// Remark plugin: a contents list (a heading followed by a numbered list of links to pages)
// becomes a set of cards, and each card carries the description of the page it links to.
// The markdown stays a plain list. Must run before the links are rewritten to routes.
export function describeContentsCards() {
  return (tree, file) => {
    const filePath = file.path ?? file.history?.[0];
    if (!filePath || !filePath.includes(CONTENT_MARKER)) return;
    const dir = path.dirname(filePath);
    tree.children.forEach((node, i) => {
      if (node.type !== 'list' || !node.ordered || tree.children[i - 1]?.type !== 'heading') return;
      const links = node.children.map(soleLink);
      if (!links.every((link) => link && link.url.endsWith('.md') && !/^[a-z]+:|^\//i.test(link.url))) return;
      node.spread = false;
      node.data = { hProperties: { className: ['contents'] } };
      node.children.forEach((item, n) => {
        item.spread = false;
        const description = descriptionOf(path.resolve(dir, links[n].url));
        item.children = [{
          type: 'paragraph',
          data: { hName: 'span', hProperties: { className: ['card-text'] } },
          children: [links[n], ...(description ? [{
            type: 'emphasis',
            data: { hName: 'span', hProperties: { className: ['card-description'] } },
            children: [{ type: 'text', value: description }],
          }] : [])],
        }];
      });
    });
  };
}
