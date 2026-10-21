// Placing a pickup order: the website writes a create-only doc to stores/essence/webOrders/{CODE};
// a till picks it up, prices it from the POS menu and holds it for collection.
import { CreateError, createDoc } from './firestore';
import { clear, lines, subtotal } from './store';

const ALPHABET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // no I, L, O, 0, 1
const LAST_KEY = 'essence.lastOrder.v1';
const COOLDOWN_MS = 45_000;

export interface PlacedOrder { code: string; at: number; phone: string; name: string; items: { name: string; qty: number }[]; subtotal: number }

export function newCode(len = 5) {
  const bytes = crypto.getRandomValues(new Uint8Array(len));
  return Array.from(bytes, (b) => ALPHABET[b % ALPHABET.length]).join('');
}

/** 0300-1234567 / +92 300 1234567 / 3001234567 → 03001234567, or null if it isn't a Pakistani mobile. */
export function normalizePhone(input: string) {
  let d = input.replace(/\D/g, '');
  if (d.startsWith('0092')) d = d.slice(2);
  if (d.startsWith('92')) d = `0${d.slice(2)}`;
  else if (d.length === 10 && d.startsWith('3')) d = `0${d}`;
  return /^03\d{9}$/.test(d) ? d : null;
}

export const lastOrder = (): PlacedOrder | null => {
  try {
    return JSON.parse(localStorage.getItem(LAST_KEY) || 'null');
  } catch {
    return null;
  }
};

export class OrderError extends Error {}

export async function placeOrder(input: { phone: string; name: string; note: string; items: { name: string; qty: number }[] }): Promise<PlacedOrder> {
  const phone = normalizePhone(input.phone);
  if (!phone) throw new OrderError('Please enter a valid mobile number, e.g. 0300 1234567.');
  const prev = lastOrder();
  if (prev && Date.now() - prev.at < COOLDOWN_MS) throw new OrderError('You just placed an order. Please wait a moment before placing another.');
  const cart = lines();
  if (!cart.length) throw new OrderError('Your cart is empty.');

  const data = {
    phone,
    name: input.name.trim().slice(0, 40),
    note: input.note.trim().slice(0, 200),
    lines: cart.slice(0, 30).map((l) => ({
      productId: l.productId,
      qty: l.qty,
      ...(l.sizeCode ? { sizeCode: l.sizeCode } : {}),
      ...(l.optionIds.length ? { optionIds: l.optionIds } : {}),
    })),
    status: 'new',
    subtotal: subtotal(),
  };

  let lastErr: unknown;
  for (let attempt = 0; attempt < 4; attempt++) {
    const code = newCode();
    try {
      await createDoc(`webOrders/${code}`, { code, ...data }, ['createdAt']);
      const placed: PlacedOrder = { code, at: Date.now(), phone, name: data.name, items: input.items, subtotal: data.subtotal };
      try {
        localStorage.setItem(LAST_KEY, JSON.stringify(placed));
      } catch {}
      clear();
      return placed;
    } catch (e) {
      lastErr = e;
      // A taken code looks like a failed precondition (or a denied update); anything else won't fix itself.
      if (!(e instanceof CreateError) || ![400, 403, 409].includes(e.status)) break;
    }
  }
  console.warn('order failed', lastErr);
  throw new OrderError('We couldn’t place your order right now. Please try again in a moment, or message us on WhatsApp.');
}

/** wa.me link to the shop with the Order ID already written. */
export function shopWhatsApp(number: string, text: string) {
  let d = number.replace(/\D/g, '');
  if (d.startsWith('0')) d = `92${d.slice(1)}`;
  return d ? `https://wa.me/${d}?text=${encodeURIComponent(text)}` : '';
}
