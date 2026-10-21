// Build step: copies the live POS menu (Firestore) into src/data/menu.json so every page ships the menu
// in its HTML (SEO). If Firestore can't be reached, the committed snapshot is kept and the build goes on.
import { readFile, writeFile } from 'node:fs/promises';
import { listCollection } from './firestore-rest.mjs';

const projectId = 'essenceisb';
const storeId = 'essence';
const apiKey = 'AIzaSyA2xR9jctSGzpWPRK0lpHWx-hfqcEy6SSM';
const emulator = process.env.FIRESTORE_EMULATOR_HOST;
const base = emulator
  ? `http://${emulator}/v1/projects/${projectId}/databases/(default)/documents/stores/${storeId}`
  : `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/stores/${storeId}`;
const target = new URL('../src/data/menu.json', import.meta.url);

const live = (d) => d.deleted !== true && d.active !== false;
const bySort = (a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0) || String(a.name).localeCompare(String(b.name));

try {
  const key = emulator ? '' : apiKey;
  const [cats, prods, groups] = await Promise.all([
    listCollection(base, 'categories', key),
    listCollection(base, 'products', key),
    listCollection(base, 'modifierGroups', key),
  ]);
  const categories = cats.filter(live).sort(bySort).map((c) => ({ id: c.id, name: c.name, sortOrder: c.sortOrder ?? 0 }));
  const catIds = new Set(categories.map((c) => c.id));
  const products = prods
    .filter((p) => live(p) && catIds.has(p.categoryId))
    .sort(bySort)
    .map((p) => ({
      id: p.id,
      categoryId: p.categoryId,
      name: p.name,
      description: p.description ?? '',
      price: p.price ?? 0,
      sizes: (p.sizes ?? []).map((s) => ({ code: s.code, label: s.label ?? s.code, delta: s.delta ?? 0 })),
      modifierGroupIds: p.modifierGroupIds ?? [],
      available: p.available !== false,
      sortOrder: p.sortOrder ?? 0,
    }));
  const used = new Set(products.flatMap((p) => p.modifierGroupIds));
  const modifierGroups = groups
    .filter((g) => g.deleted !== true && used.has(g.id))
    .map((g) => ({
      id: g.id,
      name: g.name,
      minSelect: g.minSelect ?? 0,
      maxSelect: g.maxSelect ?? 1,
      options: (g.options ?? []).map((o) => ({ id: o.id, name: o.name, delta: o.delta ?? 0 })),
    }));
  if (!products.length) throw new Error('no products returned');
  const menu = { fetchedAt: new Date().toISOString(), categories, products, modifierGroups };
  await writeFile(target, JSON.stringify(menu, null, 2) + '\n');
  console.log(`menu: ${categories.length} categories, ${products.length} products from ${emulator ? 'emulator' : 'Firestore'}`);
} catch (e) {
  const snap = JSON.parse(await readFile(target, 'utf8'));
  console.warn(`menu: couldn't reach Firestore (${e.message.split('\n')[0]}); using snapshot from ${snap.fetchedAt}`);
}
