// Everything about the shop in one place. Fields marked TODO are placeholders until the client confirms them.
// WhatsApp number, hours and address also come live from the POS (Settings › Online orders / Store profile)
// and replace these values in the browser.

export const site = {
  name: 'ESSENCE',
  tagline: 'Patisserie, Coffee & Dessert Lounge',
  url: 'https://essenceisb.web.app', // TODO: custom domain when the client has one
  locale: 'en_PK',

  area: 'Bahria Town Phase 8',
  city: 'Rawalpindi',
  region: 'Punjab',
  address: 'Burjul Sadiq Plaza No. 01, Ground Floor, Shop #06, Abu Bakar Commercial, Phase 8, Bahria Town, Rawalpindi',
  streetAddress: 'Burjul Sadiq Plaza No. 01, Ground Floor, Shop #06, Abu Bakar Commercial, Phase 8, Bahria Town',
  geo: { lat: 33.4939, lng: 73.1053 }, // TODO: exact map pin (approximate centre of Phase 8)
  mapsUrl: 'https://www.google.com/maps/search/?api=1&query=Burjul+Sadiq+Plaza+Abu+Bakar+Commercial+Phase+8+Bahria+Town+Rawalpindi', // TODO: shop's Google Maps pin link
  mapQuery: 'Abu Bakar Commercial, Phase 8, Bahria Town, Rawalpindi',

  whatsapp: '03045631810', // Shop WhatsApp (+92 304 5631810). The POS (Settings › Online orders) can override it live.
  phone: '', // TODO
  instagram: 'essence.cafe.pk',
  instagramUrl: 'https://www.instagram.com/essence.cafe.pk/',
  facebookUrl: 'https://www.facebook.com/profile.php?id=61595488500877',
  hours: '', // TODO: e.g. Daily 12 pm – 12 am
  openingHours: [] as { days: string[]; opens: string; closes: string }[], // TODO: for Google, e.g. { days: ['Monday', …], opens: '12:00', closes: '23:59' }

  firebase: {
    projectId: 'essenceisb',
    apiKey: 'AIzaSyA2xR9jctSGzpWPRK0lpHWx-hfqcEy6SSM',
    storeId: 'essence',
  },
};

export type Site = typeof site;
