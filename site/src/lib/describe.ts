// Meta description for a page: front matter `description` if set, otherwise the
// first paragraph of the markdown body, cut at a word boundary.
const LIMIT = 160;

export function describe(data: { description?: string; title?: string }, body = ''): string {
  if (data.description) return data.description;
  const paragraph = body
    .split(/\n{2,}/)
    .map((block) => block.trim())
    .find((block) => block && !/^(#|\d+\.|[-*]\s|---)/.test(block));
  const text = (paragraph ?? '')
    .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
    .replace(/[*_`]/g, '')
    .replace(/\s+/g, ' ');
  // A section page with no introduction of its own still needs a usable description.
  if (text.length < 50) {
    const lead = text || (data.title ? `${data.title}.` : '');
    return `${lead} Part of the Unified Path of Light (Synphotodosism).`.trim();
  }
  if (text.length <= LIMIT) return text;
  return `${text.slice(0, text.lastIndexOf(' ', LIMIT - 1))}…`;
}
