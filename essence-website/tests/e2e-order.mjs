// End-to-end: the built site (pointed at the Firestore emulator) places a pickup order through the UI.
// 1. firebase emulators:start --only firestore --project essenceisb   (from ../essence-pos)
// 2. PUBLIC_FIRESTORE_EMULATOR=127.0.0.1:8080 npm run build:offline && npx astro preview --port 4321
// 3. node tests/e2e-order.mjs [screenshotDir]
import puppeteer from 'puppeteer-core';
import menu from '../src/data/menu.json' with { type: 'json' };

const EMU = 'http://127.0.0.1:8080/v1/projects/essenceisb/databases/(default)/documents/stores/essence';
const admin = { Authorization: 'Bearer owner', 'Content-Type': 'application/json' };
const shots = process.argv[2];
const site = 'http://127.0.0.1:4321';

const val = (v) =>
  typeof v === 'string' ? { stringValue: v } : typeof v === 'boolean' ? { booleanValue: v } : Number.isInteger(v) ? { integerValue: String(v) } : v instanceof Date ? { timestampValue: v.toISOString() } : null;
async function put(path, data) {
  const fields = Object.fromEntries(Object.entries(data).map(([k, v]) => [k, val(v)]));
  const res = await fetch(`${EMU}/${path}`, { method: 'PATCH', headers: admin, body: JSON.stringify({ fields }) });
  if (!res.ok) throw new Error(`seed ${path}: ${res.status} ${await res.text()}`);
}
const fail = (m) => {
  console.error('FAIL:', m);
  process.exit(1);
};

// Seed: the menu as the POS publishes it (one item sold out), and an open shop with a fresh heartbeat.
await fetch('http://127.0.0.1:8080/emulator/v1/projects/essenceisb/databases/(default)/documents', { method: 'DELETE' });
for (const p of menu.products) await put(`products/${p.id}`, { name: p.name, price: p.id === 'm-tiramisu' ? 99900 : p.price, active: true, available: p.id !== 'm-banana-bread', deleted: false });
await put('public/site', { accepting: true, whatsapp: '03001234567', hours: 'Daily 12 pm – 12 am', address: 'Shop 1, Bahria Town Phase 8', intakeSeenAt: new Date() });

const browser = await puppeteer.launch({ executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', headless: true });
const page = await browser.newPage();
await page.setViewport({ width: 390, height: 844, isMobile: true, hasTouch: true, deviceScaleFactor: 2 });
page.on('pageerror', (e) => console.log('page error:', e.message));
const snap = (n) => shots && page.screenshot({ path: `${shots}/e2e_${n}.png` });

await page.goto(`${site}/menu`, { waitUntil: 'networkidle0' });
await page.waitForFunction(() => document.querySelector('[data-product="m-banana-bread"]')?.hasAttribute('data-sold'), { timeout: 8000 }).catch(() => fail('sold-out flag not applied from live data'));
const tiramisuPrice = await page.$eval('[data-product="m-tiramisu"] [data-price]', (e) => e.textContent);
if (tiramisuPrice !== 'Rs 999') fail(`live price not applied (got ${tiramisuPrice})`);
console.log('✔ live prices + sold out applied');

await page.$eval('[data-add="m-chocolate-cake"]', (b) => b.click());
await page.$eval('[data-add="m-chocolate-cake"]', (b) => b.click());
await page.$eval('[data-add="m-brownie"]', (b) => b.click());
await new Promise((r) => setTimeout(r, 900));
const count = await page.$eval('[data-cart-count]', (e) => e.textContent);
if (count !== '3') fail(`cart count ${count}`);
console.log('✔ added 3 items, badge shows 3');

await page.click('[data-open-cart]');
await page.waitForFunction(() => document.querySelector('[data-next]')?.textContent?.includes('Continue') && !document.querySelector('[data-next]').disabled, { timeout: 8000 }).catch(() => fail('checkout button never enabled'));
await new Promise((r) => setTimeout(r, 700));
await snap('1_cart');
const subtotal = await page.$eval('[data-subtotal]', (e) => e.textContent);
if (subtotal !== 'Rs 1,750') fail(`subtotal ${subtotal}`);
console.log('✔ cart drawer: subtotal', subtotal, '+ pickup banner');

await page.click('[data-next]');
await new Promise((r) => setTimeout(r, 600));
await page.type('input[name=phone]', '123');
await page.click('[data-next]');
await page.waitForSelector('[data-error]:not([hidden])');
console.log('✔ invalid phone rejected:', await page.$eval('[data-error]', (e) => e.textContent));
await page.$eval('input[name=phone]', (e) => (e.value = ''));
await page.type('input[name=phone]', '0300 1234567');
await page.type('input[name=name]', 'Ayesha');
await page.type('textarea[name=note]', 'Birthday candle please');
await snap('2_checkout');
await page.click('[data-next]');
await page.waitForSelector('[data-view="done"]:not([hidden])', { timeout: 15000 }).catch(() => fail('order was not placed'));
await new Promise((r) => setTimeout(r, 1500));
await snap('3_done');
const code = (await page.$eval('[data-done-code]', (e) => e.textContent)).replace('#', '');
const wa = await page.$eval('[data-done-wa]', (e) => e.href);
console.log('✔ order placed, code', code, 'wa link', wa);

const doc = await (await fetch(`${EMU}/webOrders/${code}`, { headers: admin })).json();
const f = doc.fields ?? fail('order doc missing');
if (f.phone.stringValue !== '03001234567' || f.status.stringValue !== 'new' || !f.createdAt.timestampValue) fail(JSON.stringify(f));
const lines = f.lines.arrayValue.values.map((v) => `${v.mapValue.fields.qty.integerValue}× ${v.mapValue.fields.productId.stringValue}`);
console.log('✔ Firestore doc:', lines.join(', '), '| name', f.name.stringValue, '| note', f.note.stringValue, '| subtotal', f.subtotal.integerValue);
if (await page.$eval('[data-cart-count]', (e) => !e.hidden)) fail('cart not cleared');

// Paused: the shop turns ordering off → checkout is blocked.
await put('public/site', { accepting: false, intakeSeenAt: new Date() });
await page.goto(`${site}/menu/chocolate-cake`, { waitUntil: 'networkidle0' });
await page.evaluate(() => sessionStorage.clear());
await page.click('[data-add="m-chocolate-cake"]');
await page.click('[data-open-cart]');
await page.waitForSelector('[data-paused]:not([hidden])', { timeout: 8000 }).catch(() => fail('paused notice not shown'));
if (!(await page.$eval('[data-next]', (b) => b.disabled))) fail('checkout allowed while paused');
await snap('4_paused');
console.log('✔ paused shop blocks checkout:', await page.$eval('[data-paused]', (e) => e.textContent));

await browser.close();
console.log('E2E OK');
