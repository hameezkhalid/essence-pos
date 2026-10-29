// Product photos, keyed by POS product id (src/assets/menu/{id}.jpg). Replace a file to change a photo.
import type { ImageMetadata } from 'astro';
import { getImage } from 'astro:assets';

const files = import.meta.glob<{ default: ImageMetadata }>('../assets/menu/*.{jpg,jpeg,png,webp}', { eager: true });
const byId = new Map(Object.entries(files).map(([path, mod]) => [path.split('/').pop()!.replace(/\.\w+$/, ''), mod.default]));

export const photoFor = (id: string): ImageMetadata | undefined => byId.get(id);

/** Small thumbnail URL for the cart (embedded in the page's menu data). */
export async function thumbFor(id: string) {
  const src = photoFor(id);
  if (!src) return '';
  const img = await getImage({ src, width: 160, height: 160, format: 'webp', quality: 70 });
  return img.src;
}

// Homepage / section photos: src/assets/home/{name}.jpg (hero-1…3, welcome, corporate, pickup-1, pickup-2).
const homeFiles = import.meta.glob<{ default: ImageMetadata }>('../assets/home/*.{jpg,jpeg,png,webp}', { eager: true });
const homeByName = new Map(Object.entries(homeFiles).map(([path, mod]) => [path.split('/').pop()!.replace(/\.\w+$/, ''), mod.default]));

export const homePhoto = (name: string): ImageMetadata | undefined => homeByName.get(name);

/** A section photo by name, or a product photo by POS id. */
export const imageFor = (key: string) => homePhoto(key) ?? photoFor(key);
