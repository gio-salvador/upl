import path from 'node:path';
import { routeFor } from './routes.mjs';

const CONTENT_MARKER = `${path.sep}content${path.sep}`;

function walk(node, visit) {
  visit(node);
  for (const child of node.children ?? []) walk(child, visit);
}

// Remark plugin: the markdown links to sibling .md files so it browses well on GitHub.
// On the site those links must point at routes instead.
export function rewriteContentLinks() {
  return (tree, file) => {
    const filePath = file.path ?? file.history?.[0];
    if (!filePath || !filePath.includes(CONTENT_MARKER)) return;
    const dir = path.dirname(filePath.split(CONTENT_MARKER).pop());
    walk(tree, (node) => {
      if (node.type !== 'link' || /^[a-z]+:|^#|^\//i.test(node.url)) return;
      const [target, hash] = node.url.split('#');
      const resolved = path.posix.normalize(path.posix.join(dir, target));
      // paper/ sits beside content/; the prebuild step copies it into public/paper.
      if (resolved.startsWith('../paper/')) return void (node.url = resolved.slice(2));
      if (resolved.startsWith('..') || !target.endsWith('.md')) return;
      const route = routeFor(resolved);
      node.url = (route ? `/${route}/` : '/') + (hash ? `#${hash}` : '');
    });
  };
}
