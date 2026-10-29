// Visual review: screenshots of the built site at desktop and phone sizes.
// Usage: npm run build:offline && npx astro preview --port 4321, then node tests/screens.mjs <outDir> [baseUrl]
import puppeteer from 'puppeteer-core';
import { mkdir } from 'node:fs/promises';

const outDir = process.argv[2] ?? 'screens';
const base = process.argv[3] ?? 'http://127.0.0.1:4321';
const chrome = process.env.CHROME ?? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
await mkdir(outDir, { recursive: true });

const browser = await puppeteer.launch({ executablePath: chrome, headless: true, args: ['--hide-scrollbars'] });
const sizes = { desktop: { width: 1440, height: 900 }, phone: { width: 390, height: 844, isMobile: true, hasTouch: true, deviceScaleFactor: 2 } };
const plan = [
  { path: '/', stops: [0, 1.5, 2.8, 3.6, 4.6, 5.6, 6.6, 7.6, 8.6, 9.6] },
  { path: '/menu', stops: [0, 1, 2] },
  { path: '/menu/chocolate-cake', stops: [0] },
  { path: '/corporate-events', stops: [0, 1, 2, 3, 4, 5] },
  { path: '/about', stops: [0, 1] },
  { path: '/contact', stops: [0, 1] },
];

for (const [name, vp] of Object.entries(sizes)) {
  const page = await browser.newPage();
  await page.setViewport(vp);
  page.on('pageerror', (e) => console.log(`[${name}] page error:`, e.message));
  page.on('console', (m) => m.type() === 'error' && console.log(`[${name}] console:`, m.text()));
  for (const { path, stops } of plan) {
    await page.goto(base + path, { waitUntil: 'networkidle0' });
    await new Promise((r) => setTimeout(r, 1800));
    const slug = path === '/' ? 'home' : path.slice(1).replace(/\//g, '_');
    for (const s of stops) {
      const y = Math.round(s * vp.height);
      await page.evaluate((y) => (window.__lenis ? window.__lenis.scrollTo(y, { immediate: true }) : window.scrollTo(0, y)), y);
      await new Promise((r) => setTimeout(r, 1400));
      const atEnd = await page.evaluate(() => window.scrollY + innerHeight >= document.documentElement.scrollHeight - 2);
      await page.screenshot({ path: `${outDir}/${name}_${slug}_${String(s).replace('.', '_')}.png` });
      if (atEnd) break;
    }
  }
  await page.close();
}
await browser.close();
console.log('screens in', outDir);
