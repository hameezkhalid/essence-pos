// Firestore security rules for the public website + the till's side of web orders.
// Run: npm run test:rules   (starts the Firestore emulator from ../essence-pos with its firestore.rules)
import { after, before, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { collection, doc, getDoc, getDocs, query, runTransaction, serverTimestamp, setDoc, updateDoc, where } from 'firebase/firestore';

const rules = readFileSync(new URL('../../essence-pos/firestore.rules', import.meta.url), 'utf8');
let env;

const store = 'stores/essence';
const order = (over = {}) => clean({
  code: 'K7QX2',
  phone: '03001234567',
  name: 'Ayesha',
  note: 'Candle please',
  lines: [{ productId: 'm-chocolate-cake', qty: 2 }],
  status: 'new',
  subtotal: 130000,
  createdAt: serverTimestamp(),
  ...over,
});
function clean(o) {
  return Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined));
}

before(async () => {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');
  env = await initializeTestEnvironment({ projectId: 'demo-essence', firestore: { rules, host, port: Number(port) } });
});
after(async () => env?.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, store), { memberUids: ['till'], adminUids: ['till'] });
    await setDoc(doc(db, `${store}/products/m-chocolate-cake`), { name: 'Chocolate Cake', price: 65000, active: true });
    await setDoc(doc(db, `${store}/categories/cat-chocolate`), { name: 'Chocolate Favourites' });
    await setDoc(doc(db, `${store}/public/site`), { accepting: true, whatsapp: '03001234567' });
    await setDoc(doc(db, `${store}/settings/fbr`), { value: { token: 'secret' } });
    await setDoc(doc(db, `${store}/staff/owner`), { name: 'Owner', pinHash: 'x' });
    await setDoc(doc(db, `${store}/orders/o1`), { total: 1 });
  });
});

const anon = () => env.unauthenticatedContext().firestore();
const till = () => env.authenticatedContext('till').firestore();
const stranger = () => env.authenticatedContext('someone').firestore();

describe('public website reads', () => {
  test('menu and store info are public', async () => {
    await assertSucceeds(getDoc(doc(anon(), `${store}/products/m-chocolate-cake`)));
    await assertSucceeds(getDocs(collection(anon(), `${store}/products`)));
    await assertSucceeds(getDocs(collection(anon(), `${store}/categories`)));
    await assertSucceeds(getDoc(doc(anon(), `${store}/public/site`)));
  });
  test('everything else stays private', async () => {
    await assertFails(getDoc(doc(anon(), `${store}/settings/fbr`)));
    await assertFails(getDoc(doc(anon(), `${store}/staff/owner`)));
    await assertFails(getDocs(collection(anon(), `${store}/orders`)));
    await assertFails(getDoc(doc(stranger(), `${store}/settings/fbr`)));
    await assertFails(setDoc(doc(anon(), `${store}/products/m-chocolate-cake`), { price: 1 }));
    await assertFails(setDoc(doc(anon(), `${store}/public/site`), { accepting: true }));
  });
});

describe('web order create', () => {
  test('a valid order is accepted', async () => {
    await assertSucceeds(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), order()));
  });
  test('only the required fields are needed', async () => {
    await assertSucceeds(setDoc(doc(anon(), `${store}/webOrders/ABCDE`), order({ code: 'ABCDE', name: undefined, note: undefined, subtotal: undefined })));
  });
  for (const [why, over, code] of [
    ['bad phone', { phone: '12345' }],
    ['extra field', { price: 1 }],
    ['status not new', { status: 'inPos' }],
    ['code mismatch', { code: 'ZZZZZ' }],
    ['look-alike characters in the code', { code: 'K7QO1' }, 'K7QO1'],
    ['no lines', { lines: [] }],
    ['too many lines', { lines: Array.from({ length: 31 }, () => ({ productId: 'm-chocolate-cake', qty: 1 })) }],
    ['client-made timestamp', { createdAt: new Date() }],
    ['long name', { name: 'x'.repeat(41) }],
    ['long note', { note: 'x'.repeat(201) }],
    ['negative subtotal', { subtotal: -5 }],
  ]) {
    test(`rejected: ${why}`, async () => {
      await assertFails(setDoc(doc(anon(), `${store}/webOrders/${code ?? 'K7QX2'}`), order(over)));
    });
  }
  test('names stripped of undefined still work', async () => {
    const o = order();
    delete o.note;
    await assertSucceeds(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), o));
  });
  test('rejected while the shop has paused ordering', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), `${store}/public/site`), { accepting: false }));
    await assertFails(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), order()));
  });
  test('the public cannot read, overwrite or change an order', async () => {
    await assertSucceeds(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), order()));
    await assertFails(getDoc(doc(anon(), `${store}/webOrders/K7QX2`)));
    await assertFails(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), order({ name: 'Mallory' })));
    await assertFails(updateDoc(doc(anon(), `${store}/webOrders/K7QX2`), { status: 'cancelled' }));
  });
});

describe('the till receives web orders', () => {
  test('lists new orders, claims one in a transaction and marks it in the POS', async () => {
    await assertSucceeds(setDoc(doc(anon(), `${store}/webOrders/K7QX2`), order()));
    const db = till();
    const pending = await assertSucceeds(getDocs(query(collection(db, `${store}/webOrders`), where('status', 'in', ['new', 'claimed']))));
    if (pending.size !== 1) throw new Error(`expected 1 pending order, got ${pending.size}`);
    const ref = doc(db, `${store}/webOrders/K7QX2`);
    const claimed = await runTransaction(db, async (tx) => {
      const snap = await tx.get(ref);
      if (snap.data().status !== 'new') return false;
      tx.update(ref, { status: 'claimed', claimedBy: 'dev-1', claimedAt: serverTimestamp() });
      return true;
    });
    if (!claimed) throw new Error('claim failed');
    await assertSucceeds(updateDoc(ref, { status: 'inPos', posOrderId: 'web-K7QX2', posSubtotal: 130000 }));
    await assertSucceeds(setDoc(doc(db, `${store}/public/site`), { intakeSeenAt: serverTimestamp() }, { merge: true }));
  });
  test('a signed-in non-member gets nothing', async () => {
    await assertFails(getDocs(collection(stranger(), `${store}/webOrders`)));
  });
});
