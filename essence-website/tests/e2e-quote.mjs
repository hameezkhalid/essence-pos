// Corporate & events "Request a Quote" on an iPhone-sized screen: validation, the WhatsApp message,
// and that "Thank you" only appears once WhatsApp has actually been opened.
// Needs a build served on :4321 (npx astro preview --port 4321). Usage: node tests/e2e-quote.mjs [screenshotDir]
import puppeteer from 'puppeteer-core';

const shots = process.argv[2];
const fail = (m) => {
  console.error('FAIL:', m);
  process.exit(1);
};
const browser = await puppeteer.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', headless: true });
const page = await browser.newPage();
await page.setViewport({ width: 390, height: 844, isMobile: true, hasTouch: true, deviceScaleFactor: 2 });
page.on('pageerror', (e) => fail(`page error: ${e.message}`));
// Record what WhatsApp would be opened with; window.__block simulates a pop-up blocker.
await page.evaluateOnNewDocument(() => {
  window.__opened = [];
  window.open = (url) => (window.__block ? null : (window.__opened.push(url), { opener: 1 }));
});

await page.goto('http://127.0.0.1:4321/corporate-events', { waitUntil: 'networkidle0' });
const hero = await page.$eval('[data-wa-raw]', (a) => ({ hidden: a.hidden, href: decodeURIComponent(a.href) }));
if (hero.hidden || !hero.href.includes('Hello ESSENCE, I would like to enquire about a corporate order or event. Event type: ____.')) fail(`hero WhatsApp link: ${JSON.stringify(hero)}`);
console.log('✔ "Enquire on WhatsApp" opens the brief’s pre-filled message');

await page.$eval('[data-quote] button[type=submit]', (b) => b.click());
const err = await page.$eval('[data-quote-error]', (e) => (e.hidden ? '' : e.textContent));
if (!/your name/.test(err) || !/phone/.test(err) || !/enquiry type/.test(err)) fail(`validation: ${err}`);
if (await page.$eval('[data-quote-done]', (e) => !e.hidden)) fail('success shown for an empty form');
console.log('✔ empty form blocked:', err);

await page.type('input[name=name]', 'Sara Ahmed');
await page.type('input[name=company]', 'Acme Pvt Ltd');
await page.type('input[name=phone]', '0321 5550000');
await page.select('select[name=type]', 'Corporate order');
await page.$eval('input[name=date]', (e) => (e.value = '2026-11-12'));
await page.type('input[name=guests]', '40');
await page.type('input[name=location]', 'Bahria Town Phase 7');
await page.type('input[name=items]', 'Brownies and cookies');
await page.type('textarea[name=details]', 'Afternoon team meeting');
if (shots) await page.screenshot({ path: `${shots}/quote_filled.png`, fullPage: false });
await page.$eval('[data-quote] button[type=submit]', (b) => b.click());
await page.waitForSelector('[data-quote-done]:not([hidden])', { timeout: 4000 }).catch(() => fail('no success after opening WhatsApp'));
const opened = await page.evaluate(() => window.__opened.map(decodeURIComponent));
if (opened.length !== 1 || !opened[0].startsWith('https://wa.me/923045631810?text=Hello ESSENCE')) fail(`opened: ${opened}`);
for (const want of ['Name: Sara Ahmed', 'Company: Acme Pvt Ltd', 'Phone/WhatsApp: 0321 5550000', 'Event type: Corporate order', 'Date: Thu, 12 November 2026', 'Approximate guests/quantity: 40', 'Location: Bahria Town Phase 7', 'Items/services required: Brownies and cookies', 'Details: Afternoon team meeting', 'Please let me know availability and the next steps.']) {
  if (!opened[0].includes(want)) fail(`message missing "${want}":\n${opened[0]}`);
}
if (opened[0].includes('Email:')) fail('empty email should be left out');
await new Promise((r) => setTimeout(r, 1200));
if (shots) await page.screenshot({ path: `${shots}/quote_done.png` });
console.log('✔ WhatsApp opened with:\n' + opened[0].split('?text=')[1].replace(/^/gm, '    '));
console.log('✔ success shown:', await page.$eval('[data-quote-done-title]', (e) => e.textContent));

// Pop-up blocked: no success until the customer taps the send button.
await page.click('[data-quote-reset]');
await page.evaluate(() => (window.__block = true));
await page.type('input[name=name]', 'Ali');
await page.type('input[name=phone]', '03001234567');
await page.select('select[name=type]', 'Celebration');
await page.$eval('[data-quote] button[type=submit]', (b) => b.click());
await page.waitForSelector('[data-quote-blocked]:not([hidden])', { timeout: 4000 }).catch(() => fail('blocked state not shown'));
if (await page.$eval('[data-quote-done]', (e) => !e.hidden)) fail('success shown although WhatsApp did not open');
const href = await page.$eval('[data-quote-blocked-open]', (a) => decodeURIComponent(a.href));
if (!href.includes('Name: Ali') || !href.includes('Event type: Celebration')) fail(`blocked link: ${href}`);
console.log('✔ pop-up blocked → "Send on WhatsApp" button, no premature success');

await browser.close();
console.log('QUOTE E2E OK');
