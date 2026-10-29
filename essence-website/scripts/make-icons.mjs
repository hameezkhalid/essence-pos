// Generates favicons, app icons and the 1200×630 social share image into public/.
// Run after changing the logo or the hero photos: npm run icons
import sharp from 'sharp';
import { writeFile } from 'node:fs/promises';

const out = (f) => new URL(`../public/${f}`, import.meta.url).pathname;
const logo = new URL('../src/assets/logo.png', import.meta.url).pathname;
const photo = (name) => new URL(`../src/assets/home/${name}.jpg`, import.meta.url).pathname;

// The badge logo on a cream disc (it already has a transparent corner area).
const icon = (size) => sharp(logo).resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } });
await icon(192).png().toFile(out('icon-192.png'));
await icon(512).png().toFile(out('icon-512.png'));
await sharp(logo).resize(180, 180).flatten({ background: '#f9f5ec' }).png().toFile(out('apple-touch-icon.png'));

// favicon.ico holding a 32px and a 48px PNG.
const pngs = await Promise.all([32, 48].map((s) => icon(s).png().toBuffer()));
const header = Buffer.alloc(6 + 16 * pngs.length);
header.writeUInt16LE(0, 0);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(pngs.length, 4);
let offset = header.length;
pngs.forEach((png, i) => {
  const s = [32, 48][i];
  const e = 6 + i * 16;
  header.writeUInt8(s, e);
  header.writeUInt8(s, e + 1);
  header.writeUInt16LE(1, e + 4);
  header.writeUInt16LE(32, e + 6);
  header.writeUInt32LE(png.length, e + 8);
  header.writeUInt32LE(offset, e + 12);
  offset += png.length;
});
await writeFile(out('favicon.ico'), Buffer.concat([header, ...pngs]));

// Share image: deep chocolate, three arched desserts, the wordmark.
const W = 1200;
const H = 630;
const arch = async (id, w, h) => {
  const mask = Buffer.from(`<svg width="${w}" height="${h}"><rect x="0" y="0" width="${w}" height="${h}" rx="${w / 2}" ry="${w / 2}"/><rect x="0" y="${h / 2}" width="${w}" height="${h / 2}" rx="18" ry="18"/></svg>`);
  return sharp(photo(id)).resize(w, h, { fit: 'cover' }).composite([{ input: mask, blend: 'dest-in' }]).png().toBuffer();
};
const bg = Buffer.from(`<svg width="${W}" height="${H}" xmlns="http://www.w3.org/2000/svg">
  <defs><radialGradient id="g" cx="72%" cy="40%" r="80%"><stop offset="0" stop-color="#3a2418"/><stop offset=".65" stop-color="#22150e"/></radialGradient></defs>
  <rect width="100%" height="100%" fill="url(#g)"/>
  <text x="70" y="250" font-family="Playfair Display, Georgia, serif" font-size="96" fill="#f6efe2">Essence</text>
  <text x="74" y="306" font-family="Helvetica, Arial, sans-serif" font-size="17" letter-spacing="5" fill="#d9b77e">PATISSERIE · COFFEE · DESSERT LOUNGE</text>
  <text x="70" y="400" font-family="Playfair Display, Georgia, serif" font-style="italic" font-size="46" fill="#f6efe2">A Little Taste of Happiness</text>
  <text x="72" y="452" font-family="Helvetica, Arial, sans-serif" font-size="24" fill="#c9bba5">Coffee, cakes &amp; desserts · Bahria Town Phase 8</text>
</svg>`);
await sharp(bg)
  .composite([
    { input: await arch('hero-2', 200, 260), left: 650, top: 300 },
    { input: await arch('hero-1', 260, 340), left: 790, top: 120 },
    { input: await arch('hero-3', 190, 250), left: 990, top: 290 },
  ])
  .jpeg({ quality: 86, mozjpeg: true })
  .toFile(out('og-image.jpg'));

console.log('icons + og-image written to public/');
