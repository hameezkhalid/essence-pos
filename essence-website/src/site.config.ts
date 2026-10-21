// Everything about the shop in one place. Fields marked TODO are placeholders until the client confirms them.
// WhatsApp number, hours and address also come live from the POS (Settings › Online orders / Store profile)
// and replace these values in the browser.

export const site = {
  name: 'Essence',
  tagline: 'Patisserie · Coffee · Dessert',
  url: 'https://essenceisb.web.app', // TODO: custom domain when the client has one
  locale: 'en_PK',

  area: 'Bahria Town Phase 8',
  city: 'Rawalpindi',
  region: 'Punjab',
  address: 'Bahria Town Phase 8, Rawalpindi', // TODO: exact shop address
  geo: { lat: 33.4939, lng: 73.1053 }, // TODO: exact map pin (approximate centre of Phase 8)
  mapsUrl: 'https://www.google.com/maps/search/?api=1&query=Essence+Bahria+Town+Phase+8+Rawalpindi', // TODO: shop's Google Maps link

  whatsapp: '', // TODO: shop WhatsApp, e.g. 03001234567
  phone: '', // TODO
  instagram: '', // TODO: handle without @
  hours: '', // TODO: e.g. Daily 12 pm – 12 am
  openingHours: [] as { days: string[]; opens: string; closes: string }[], // TODO: for Google, e.g. { days: ['Monday', …], opens: '12:00', closes: '23:59' }

  firebase: {
    projectId: 'essenceisb',
    apiKey: 'AIzaSyA2xR9jctSGzpWPRK0lpHWx-hfqcEy6SSM',
    storeId: 'essence',
  },
};

export type Site = typeof site;
