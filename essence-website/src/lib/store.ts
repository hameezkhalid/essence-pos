// Browser state: the menu (from the page, refreshed live), the cart (localStorage) and whether ordering is open.
import type { ModifierGroup, Product } from './menu';
import { getDoc, listDocs } from './firestore';
import { site } from '../site.config';

export interface ClientProduct extends Product { thumb: string; url: string }
export interface CartLine { key: string; productId: string; qty: number; sizeCode?: string; optionIds: string[] }
export interface SiteStatus {
  /** Orders can be placed right now. */
  open: boolean;
  /** Why not: the shop paused ordering, no till is receiving, or we couldn't check. */
  reason?: 'paused' | 'away' | 'unknown';
  whatsapp: string;
  hours: string;
  address: string;
}

const CART_KEY = 'essence.cart.v1';
const LIVE_KEY = 'essence.live.v1';
const LIVE_TTL = 90_000;
/** A till reports in every 5 minutes; after this long without one, nobody is receiving orders. */
const INTAKE_STALE_MS = 15 * 60_000;

const data = JSON.parse(document.getElementById('menu-data')?.textContent || '{"products":[],"modifierGroups":[]}') as {
  products: ClientProduct[];
  modifierGroups: ModifierGroup[];
};
export const products = new Map(data.products.map((p) => [p.id, p]));
export const groups = new Map(data.modifierGroups.map((g) => [g.id, g]));

const safe = <T>(f: () => T, fallback: T): T => {
  try {
    return f();
  } catch {
    return fallback;
  }
};

let cart: CartLine[] = safe(() => JSON.parse(localStorage.getItem(CART_KEY) || '[]'), []);
export let status: SiteStatus = { open: false, reason: 'unknown', whatsapp: site.whatsapp, hours: site.hours, address: site.address };

type Listener = () => void;
const listeners = new Set<Listener>();
export const subscribe = (fn: Listener) => (listeners.add(fn), () => listeners.delete(fn));
const emit = () => listeners.forEach((fn) => fn());

function save() {
  cart = cart.filter((l) => products.has(l.productId) && l.qty > 0);
  safe(() => localStorage.setItem(CART_KEY, JSON.stringify(cart)), undefined);
  emit();
}

export const lines = () => cart;
export const count = () => cart.reduce((a, l) => a + l.qty, 0);

export function unitPrice(l: Pick<CartLine, 'productId' | 'sizeCode' | 'optionIds'>) {
  const p = products.get(l.productId);
  if (!p) return 0;
  const size = p.sizes.find((s) => s.code === l.sizeCode)?.delta ?? 0;
  const opts = p.modifierGroupIds
    .flatMap((g) => groups.get(g)?.options ?? [])
    .filter((o) => l.optionIds.includes(o.id))
    .reduce((a, o) => a + o.delta, 0);
  return p.price + size + opts;
}

export const subtotal = () => cart.reduce((a, l) => a + unitPrice(l) * l.qty, 0);

export function describe(l: CartLine) {
  const p = products.get(l.productId);
  if (!p) return '';
  const size = p.sizes.find((s) => s.code === l.sizeCode)?.label;
  const opts = p.modifierGroupIds.flatMap((g) => groups.get(g)?.options ?? []).filter((o) => l.optionIds.includes(o.id)).map((o) => o.name);
  return [size, ...opts].filter(Boolean).join(' · ');
}

export function add(productId: string, opts: { qty?: number; sizeCode?: string; optionIds?: string[] } = {}) {
  const p = products.get(productId);
  if (!p) return;
  const sizeCode = opts.sizeCode ?? (p.sizes.length ? (p.sizes.find((s) => s.delta === 0) ?? p.sizes[0]).code : undefined);
  const optionIds = [...(opts.optionIds ?? [])].sort();
  const sig = `${productId}|${sizeCode ?? ''}|${optionIds.join(',')}`;
  const found = cart.find((l) => `${l.productId}|${l.sizeCode ?? ''}|${l.optionIds.join(',')}` === sig);
  if (found) found.qty = Math.min(20, found.qty + (opts.qty ?? 1));
  else cart.push({ key: `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`, productId, qty: Math.min(20, opts.qty ?? 1), sizeCode, optionIds });
  save();
}

export function setQty(key: string, qty: number) {
  const l = cart.find((x) => x.key === key);
  if (!l) return;
  l.qty = Math.max(0, Math.min(20, qty));
  save();
}

export function clear() {
  cart = [];
  save();
}

// ───────────── Live menu & ordering status ─────────────

interface Live {
  at: number;
  prices: Record<string, { price: number; available: boolean; active: boolean }>;
  site: { accepting?: boolean; intakeSeenAt?: string; whatsapp?: string; hours?: string; address?: string } | null;
}

function apply(live: Live) {
  for (const [id, v] of Object.entries(live.prices)) {
    const p = products.get(id);
    if (!p) continue;
    p.price = v.price;
    p.available = v.available && v.active;
  }
  const s = live.site;
  const seen = s?.intakeSeenAt ? Date.parse(s.intakeSeenAt) : 0;
  const away = !seen || Date.now() - seen > INTAKE_STALE_MS;
  status = {
    open: !!s?.accepting && !away,
    // No store info yet means no till has switched online ordering on.
    reason: !s?.accepting ? 'paused' : away ? 'away' : undefined,
    whatsapp: s?.whatsapp || site.whatsapp,
    hours: s?.hours || site.hours,
    address: s?.address || site.address,
  };
  emit();
}

/** Refreshes prices, sold-out flags and the ordering switch from the POS (cached briefly across pages). */
export async function refreshLive(force = false) {
  const cached = safe<Live | null>(() => JSON.parse(sessionStorage.getItem(LIVE_KEY) || 'null'), null);
  if (cached && !force && Date.now() - cached.at < LIVE_TTL) return apply(cached);
  try {
    const [docs, siteDoc] = await Promise.all([listDocs<any>('products'), getDoc<any>('public/site')]);
    const live: Live = {
      at: Date.now(),
      prices: Object.fromEntries(
        docs.filter((d) => products.has(d.id)).map((d) => [d.id, { price: d.price ?? 0, available: d.available !== false, active: d.active !== false && d.deleted !== true }]),
      ),
      site: siteDoc,
    };
    safe(() => sessionStorage.setItem(LIVE_KEY, JSON.stringify(live)), undefined);
    apply(live);
  } catch {
    status = { ...status, open: false, reason: 'unknown' };
    emit();
  }
}
