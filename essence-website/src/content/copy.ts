// Website copy, from the client's "Website Content & Developer Brief" (reference/ESSENCE_Website_Content_Developer_Brief.docx).
// Guardrails from the brief: no prices, and no claims about ingredients, allergens, freshness, handmade production or
// delivery unless ESSENCE confirms them. Corporate, events and catering services are enquiry-based.

export const brand = {
  name: 'ESSENCE',
  full: 'ESSENCE Patisserie, Coffee & Dessert Lounge',
  location: 'Bahria Town Phase 8, Rawalpindi, Pakistan',
};

export const seo = {
  home: {
    title: 'ESSENCE | Cakes, Desserts & Coffee in Bahria Town Phase 8',
    description:
      'Explore cakes, cheesecakes, brownies, cookies, desserts and coffee at ESSENCE Patisserie, Coffee & Dessert Lounge in Bahria Town Phase 8, Rawalpindi.',
  },
  menu: {
    title: 'Menu | Cakes, Cheesecakes, Brownies & Desserts | ESSENCE Bahria Town',
    description:
      'The ESSENCE menu: chocolate cake, fudge brownies, blueberry and salted caramel cheesecake, tiramisu, tres leches, cookies and more in Bahria Town Phase 8, Rawalpindi.',
  },
  corporate: {
    title: 'Corporate Dessert Orders & Events | ESSENCE Rawalpindi',
    description:
      'Enquire about cakes, brownies, dessert selections and coffee options for office meetings, corporate orders and celebrations in Rawalpindi.',
  },
  about: {
    title: 'About ESSENCE | Patisserie, Coffee & Dessert Lounge, Bahria Town Phase 8',
    description:
      'ESSENCE Patisserie, Coffee & Dessert Lounge brings together cakes, desserts and coffee for everyday treats and memorable occasions in Bahria Town Phase 8, Rawalpindi.',
  },
  contact: {
    title: 'Contact ESSENCE | Bahria Town Phase 8, Rawalpindi',
    description:
      'Get in touch with ESSENCE in Bahria Town Phase 8, Rawalpindi for menu enquiries, orders and event requests. WhatsApp us or find us on the map.',
  },
};

export const nav = [
  { href: '/', label: 'Home' },
  { href: '/menu', label: 'Menu' },
  { href: '/corporate-events', label: 'Corporate & Events' },
  { href: '/about', label: 'About Us' },
  { href: '/contact', label: 'Contact' },
];

// ───────────── Home ─────────────

export const hero = {
  eyebrow: 'ESSENCE · Patisserie, Coffee & Dessert Lounge',
  title: ['Coffee, Cakes & Desserts', 'in Bahria Town Phase 8'],
  sub: 'Discover delicious cakes, creamy cheesecakes, tempting desserts and coffee favourites at ESSENCE. A little something to make your everyday moments and special occasions sweeter.',
  primary: 'Explore the Menu',
  secondary: 'Order Now',
  script: 'Sweet moments, better here',
};

export const marquee = ['Coffee', 'Cakes', 'Cheesecakes', 'Brownies', 'Cookies', 'Desserts', 'Bahria Town Phase 8'];

export const intro = {
  kicker: 'Welcome to ESSENCE',
  lines: ['A Little', 'Taste of', 'Happiness'],
  body: 'Welcome to ESSENCE Patisserie, Coffee & Dessert Lounge — a place for dessert cravings, coffee breaks and sweet moments worth sharing. Explore our selection of cakes, cheesecakes, brownies, cookies and more.',
  link: 'Explore the Menu',
  bg: 'Sweet moments',
};

export const featured = {
  kicker: 'The menu',
  title: 'Find Your New Favourite',
  body: 'From rich chocolate treats to fruity and creamy favourites, discover something delicious for your next coffee break, celebration or everyday treat.',
  button: 'View Full Menu',
};

export const gatherings = {
  kicker: 'Corporate & celebrations',
  title: 'Making Gatherings Sweeter',
  body: 'Planning a team meeting, celebration or special event? Get in touch with ESSENCE to discuss dessert boxes, cakes and tailored food-and-drink enquiries for your occasion.',
  button: 'Corporate & Events Enquiries',
  tiles: [
    { label: 'Team meetings', line: 'A sweeter break for your team.', image: 'pickup-2', alt: 'ESSENCE dessert boxes and coffee' },
    { label: 'Celebrations', line: 'Cakes for special moments.', image: 'm-chocolate-cake', alt: 'ESSENCE chocolate cake' },
    { label: 'Client gifts', line: 'Dessert boxes to say thank you.', image: 'corporate', alt: 'ESSENCE gift boxes for corporate orders' },
  ],
};

export const pickup = {
  title: 'Order ahead. Pick up. Enjoy.',
  steps: [
    { title: 'Pick your treats', text: 'Add your favourites to the cart.' },
    { title: 'Place with your phone', text: 'No account. Just your number.' },
    { title: 'Collect in store', text: 'Show your Order ID at the counter.' },
  ],
  banner: 'Pickup only. Collect your order at ESSENCE, Bahria Town Phase 8, using your Order ID.',
  confirm: 'We’ll confirm your order on WhatsApp. Pay when you collect.',
};

export const visit = {
  kicker: 'Visit or contact us',
  title: 'Find ESSENCE',
  body: 'Visit or contact ESSENCE in Bahria Town Phase 8, Rawalpindi. Get in touch for menu enquiries, orders and event requests.',
  button: 'Contact Us',
};

export const contact = {
  title: 'Get in Touch',
  body: 'Have a question about our menu, an order or an upcoming event? Contact ESSENCE and we’ll help you with the next steps.',
};

// ───────────── Menu ─────────────

export const menuIntro = {
  eyebrow: 'Cakes · Cheesecakes · Brownies · Cookies',
  body: [
    'From rich chocolate treats to fruity and creamy favourites, discover something delicious for your next coffee break, celebration or everyday treat.',
    'Order online and collect from ESSENCE in Bahria Town Phase 8, Rawalpindi. Place your order with just your phone number, then pick it up with your Order ID. Questions about an item? Ask us on WhatsApp.',
  ],
};

export const categoryLines: Record<string, string> = {
  'cat-chocolate': 'Rich flavours, timeless classics.',
  'cat-fruity': 'Bright flavours, pure indulgence.',
  'cat-signature': 'Classic recipes, modern touches.',
};

/** Approved card descriptions from the brief (they replace the POS descriptions on the website). Keyed by POS product id. */
export const productDescriptions: Record<string, string> = {
  'm-brownie': 'A rich, chocolatey brownie with a soft, fudgy bite — a satisfying treat for anyone craving deep chocolate flavour.',
  'm-lemon-tart': 'A bright, zesty lemon filling paired with a delicate tart shell for a refreshing balance of tangy and sweet.',
  'm-tres-leches': 'A soft, indulgent cake inspired by the classic three-milk dessert, with a moist texture and a creamy finish.',
  'm-tiramisu': 'A classic coffee-inspired dessert layered with creamy richness and delicate flavours for a smooth, indulgent finish.',
  'm-blueberry-cheesecake': 'Smooth, creamy cheesecake topped with blueberry flavour on a buttery biscuit-style base — a lovely balance of creamy and fruity.',
  'm-salted-caramel-cheesecake': 'Creamy cheesecake paired with the rich sweetness of caramel and a hint of salt for a delicious sweet-and-salty contrast.',
  'm-chocolate-cake': 'A chocolate-lover’s favourite, with a soft cake texture and rich chocolate flavour for celebrations or everyday treats.',
  'm-banana-bread': 'A comforting banana bake with a soft texture and naturally sweet banana flavour — perfect alongside your favourite coffee.',
  'm-marble-cake': 'A classic combination of chocolate and vanilla flavours swirled together in one soft, satisfying slice.',
  'm-lemon-cake': 'A light, lemon-flavoured cake with a fresh citrus note — a simple, uplifting choice for tea or coffee time.',
  'm-og-cookies': 'A classic cookie treat with a satisfying bite and familiar, comforting flavour — perfect for a little everyday indulgence.',
};

export const unavailable = 'Currently unavailable';

export const faqs = [
  {
    q: 'Do you deliver?',
    a: 'Online orders are for pickup. Place your order on the website, then collect it from ESSENCE in Bahria Town Phase 8 with your Order ID.',
  },
  {
    q: 'Do I need an account to order?',
    a: 'No. Add your items to the cart and place the order with your phone number. We confirm on WhatsApp with your Order ID.',
  },
  {
    q: 'How do I pay?',
    a: 'You pay at the counter when you collect your order.',
  },
  {
    q: 'Can I order for an office meeting or event?',
    a: 'Yes, send us an enquiry from the Corporate & Events page or on WhatsApp, and we’ll discuss availability and a suitable option for your date.',
  },
];

// ───────────── Corporate, Events & Catering ─────────────

export const corporate = {
  title: 'Corporate, Events & Catering',
  headline: 'Make Every Occasion Special',
  body: 'From office meetings and client gifts to birthdays and private celebrations, ESSENCE can help you explore dessert and coffee options for your occasion. Tell us what you have in mind and our team will discuss a suitable option with you.',
  primary: 'Request a Quote',
  secondary: 'Enquire on WhatsApp',
  note: 'All corporate, event and catering services are enquiry-based. We’ll confirm items, quantities and availability for your date.',
  sections: [
    {
      id: 'corporate',
      kicker: 'Corporate & Business Orders',
      title: 'A Sweeter Break for Your Team',
      body: 'Planning a meeting, staff celebration or client gathering? Enquire about brownies, cookies, cakes and dessert selections for your workplace. Share your requirements and preferred date so we can discuss availability and a suitable order.',
      bullets: ['Office meetings', 'Staff celebrations', 'Client gifts', 'Bulk dessert enquiries'],
      image: 'pickup-2',
      alt: 'ESSENCE dessert boxes and coffee for the office',
    },
    {
      id: 'celebrations',
      kicker: 'Events & Celebrations',
      title: 'Sweet Details for Special Moments',
      body: 'Make birthdays, anniversaries, family gatherings and other celebrations feel extra special with cakes and dessert selections from ESSENCE. Contact us to discuss the occasion, guest count, preferred items and any custom requests.',
      bullets: ['Birthday and anniversary orders', 'Dessert boxes and platters', 'Cakes for celebrations', 'Custom dessert enquiries'],
      image: 'hero-2',
      alt: 'ESSENCE chocolate cake for celebrations',
    },
    {
      id: 'catering',
      kicker: 'Catering & Coffee',
      title: 'Desserts and Coffee for Your Gathering',
      body: 'Looking for dessert or coffee options for a meeting or event? Send us your event details and we will confirm which items, quantities and service options may be available for your date.',
      bullets: ['Dessert selections', 'Coffee enquiries', 'Quantities for your guest count', 'Availability confirmed for your date'],
      image: 'pickup-1',
      alt: 'ESSENCE desserts and coffee packed for a gathering',
    },
  ],
  form: {
    kicker: 'Request a Quote',
    title: 'Tell us about your occasion',
    intro: 'Fill in what you know. Sending opens WhatsApp with your details ready, so our team receives them straight away.',
    types: ['Corporate order', 'Celebration', 'Dessert catering', 'Coffee enquiry', 'Other'],
    submit: 'Send Enquiry',
    success: 'Thank you for contacting ESSENCE.',
    successBody: 'WhatsApp has opened with your enquiry. Press Send in WhatsApp so it reaches our team, and we’ll get in touch to discuss availability and next steps.',
  },
  whatsapp:
    'Hello ESSENCE, I would like to enquire about a corporate order or event. Event type: ____. Date: ____. Approximate guests/quantity: ____. Location: ____. Items/services required: ____. Please let me know availability and the next steps.',
};

// ───────────── About ─────────────

export const about = {
  title: 'About ESSENCE',
  body: 'ESSENCE Patisserie, Coffee & Dessert Lounge brings together cakes, desserts and coffee for everyday treats and memorable occasions. Based in Bahria Town Phase 8, Rawalpindi, ESSENCE is creating a welcoming destination for people who love to pause, connect and enjoy something sweet.',
  pillars: [
    { title: 'Cakes & desserts', text: 'Cakes, cheesecakes, brownies, cookies and more.' },
    { title: 'Coffee favourites', text: 'For coffee breaks and catch-ups.' },
    { title: 'Sweet occasions', text: 'Everyday treats and memorable celebrations.' },
  ],
};
