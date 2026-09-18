// Draws the default social sharing image and writes public/og-default.png.
// Run by hand when the design changes: node scripts/generate-og.mjs
import sharp from 'sharp';

const rays = Array.from({ length: 16 }, (_, i) => {
  const a = (i * Math.PI) / 8;
  const [r1, r2] = i % 2 ? [92, 128] : [92, 150];
  const p = (r) => `${(600 + r * Math.cos(a)).toFixed(1)} ${(230 + r * Math.sin(a)).toFixed(1)}`;
  return `<path d="M${p(r1)} L${p(r2)}"/>`;
}).join('');

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <defs><radialGradient id="glow" cx="50%" cy="36%" r="60%">
    <stop offset="0" stop-color="#3a3016"/><stop offset="1" stop-color="#16150f"/>
  </radialGradient></defs>
  <rect width="1200" height="630" fill="url(#glow)"/>
  <g stroke="#e3b45c" stroke-width="6" stroke-linecap="round">${rays}</g>
  <circle cx="600" cy="230" r="62" fill="#e3b45c"/>
  <text x="600" y="470" text-anchor="middle" font-family="Georgia, 'Times New Roman', serif" font-size="68" fill="#ece7da">Unified Path of Light</text>
  <text x="600" y="540" text-anchor="middle" font-family="Georgia, 'Times New Roman', serif" font-size="34" font-style="italic" fill="#a39c8b">Synphotodosism: the way of coming together in light</text>
</svg>`;

await sharp(Buffer.from(svg)).png({ compressionLevel: 9 }).toFile(new URL('../public/og-default.png', import.meta.url).pathname);
console.log('wrote public/og-default.png');
