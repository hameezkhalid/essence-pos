// Menu types and helpers shared by pages (build time) and the browser.
import menuJson from '../data/menu.json';
import { productDescriptions } from '../content/copy';

export interface Size { code: string; label: string; delta: number }
export interface Option { id: string; name: string; delta: number }
export interface ModifierGroup { id: string; name: string; minSelect: number; maxSelect: number; options: Option[] }
export interface Category { id: string; name: string; sortOrder: number }
export interface Product {
  id: string;
  categoryId: string;
  name: string;
  description: string;
  /** Paisa (Rs 1 = 100). */
  price: number;
  sizes: Size[];
  modifierGroupIds: string[];
  available: boolean;
  sortOrder: number;
}
export interface Menu { fetchedAt: string; categories: Category[]; products: Product[]; modifierGroups: ModifierGroup[] }

const raw = menuJson as Menu;

/** The POS menu, with the client's approved website descriptions in place of the POS ones. */
export const menu: Menu = {
  ...raw,
  products: raw.products.map((p) => ({ ...p, description: productDescriptions[p.id] ?? p.description })),
};

/** Rs 1,250 */
export const rs = (paisa: number) => `Rs ${Math.round(paisa / 100).toLocaleString('en-US')}`;

/** Stable URL slug from the POS product id (m-chocolate-cake → chocolate-cake). */
export const slugOf = (id: string) => id.replace(/^m-/, '');

export const productsIn = (categoryId: string) => menu.products.filter((p) => p.categoryId === categoryId);

export const categoryOf = (p: Product) => menu.categories.find((c) => c.id === p.categoryId);

/** Lowest price shown on a card ("from" when sizes add to it). */
export function fromPrice(p: Product) {
  const deltas = p.sizes.map((s) => s.delta);
  return p.price + (deltas.length ? Math.min(...deltas) : 0);
}

export const hasOptions = (p: Product) => p.sizes.length > 1 || p.modifierGroupIds.length > 0;

