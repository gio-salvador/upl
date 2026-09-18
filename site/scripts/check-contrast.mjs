// Colour contrast gate. Reads the colour tokens from src/styles/global.css, for the light and
// the dark theme, and asserts that every text colour reaches WCAG 2.2 AA (4.5 to 1) against the
// page background and the card surface. Links are body text here, so the accent is held to the
// same ratio. --gold is ornament only and is not checked.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const MINIMUM = 4.5;
const TEXT_TOKENS = ['fg', 'muted', 'accent'];
const BACKGROUNDS = ['bg', 'surface'];
const css = readFileSync(fileURLToPath(new URL('../src/styles/global.css', import.meta.url)), 'utf8');

const tokens = (block) => Object.fromEntries([...block.matchAll(/--([a-z-]+):\s*(#[0-9a-f]{6})/gi)].map((m) => [m[1], m[2]]));
const light = tokens(css.match(/:root\s*{([^}]*)}/)?.[1] ?? '');
const dark = { ...light, ...tokens(css.match(/prefers-color-scheme:\s*dark\)\s*{\s*:root\s*{([^}]*)}/)?.[1] ?? '') };

const luminance = (hex) => {
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255).map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const ratio = (a, b) => {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

const problems = [];
for (const [theme, set] of Object.entries({ light, dark })) {
  for (const name of [...TEXT_TOKENS, ...BACKGROUNDS]) if (!set[name]) problems.push(`${theme}: no --${name} token found in global.css`);
  for (const name of TEXT_TOKENS.filter((n) => set[n])) {
    for (const ground of BACKGROUNDS.filter((g) => set[g])) {
      const value = ratio(set[name], set[ground]);
      if (value < MINIMUM) problems.push(`${theme}: --${name} ${set[name]} on --${ground} ${set[ground]} is ${value.toFixed(2)} to 1, needs ${MINIMUM}`);
    }
  }
}
if (problems.length) {
  for (const problem of problems) console.error(`check-contrast: ${problem}`);
  process.exit(1);
}
console.log(`check-contrast: ${TEXT_TOKENS.join(', ')} reach ${MINIMUM} to 1 on ${BACKGROUNDS.join(' and ')} in light and dark`);
