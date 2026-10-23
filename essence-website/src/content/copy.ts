// Website copy. On-screen text stays short; longer SEO paragraphs live on /menu and the item pages.
// Built from the client's brief and the printed menu ("Handcrafted · Freshly baked · Always delicious").

export const seo = {
  home: {
    title: 'Essence | Rich Chocolate Cakes & Desserts in Bahria Town Phase 8',
    description:
      'Rich chocolate cakes, cheesecakes, tiramisu and freshly baked desserts at Essence, Bahria Town Phase 8, Rawalpindi. Order online and pick up in store.',
  },
  menu: {
    title: 'Dessert Menu | Cakes, Cheesecakes & Brownies | Essence Bahria Town',
    description:
      'The full Essence dessert menu: rich chocolate cake, fudge brownies, blueberry and salted caramel cheesecake, tiramisu, tres leches and more. Order online for pickup in Bahria Town Phase 8.',
  },
};

export const hero = {
  eyebrow: 'Rich chocolate · Bahria Town Phase 8',
  title: ['Beautifully', 'indulgent.'],
  sub: 'Unforgettably delicious. Made for your sweetest moments.',
  script: 'Sweet moments, better here',
};

export const marquee = ['Rich Chocolate', 'Freshly Baked', 'Handcrafted', 'Bahria Town Phase 8', 'Order for Pickup'];

export const story = {
  kicker: 'The rich chocolate cake',
  beats: ['Deep, rich chocolate.', 'A texture that melts.', 'Made to be shared.'],
  body:
    'Discover the irresistible indulgence of rich chocolate cakes, where deep chocolate flavours meet a delightful texture to create a truly indulgent treat.',
};

export const moments = {
  title: 'Made for your sweetest moments',
  intro:
    'Whether you’re celebrating a special occasion, sharing a moment with loved ones, or simply treating yourself, every cake is an invitation to make life’s sweetest moments even more memorable.',
  tiles: [
    { label: 'Celebrations', line: 'Birthdays, anniversaries, the big news.', product: 'm-chocolate-cake' },
    { label: 'With loved ones', line: 'Slices made for sharing.', product: 'm-tres-leches' },
    { label: 'Just for you', line: 'Because today deserves it.', product: 'm-tiramisu' },
  ],
};

export const pickup = {
  title: 'Order ahead. Pick up. Indulge.',
  steps: [
    { title: 'Pick your treats', text: 'Add your favourites to the cart.' },
    { title: 'Place with your phone', text: 'No account. Just your number.' },
    { title: 'Collect in store', text: 'Show your Order ID at the counter.' },
  ],
  banner: 'Pickup only. Collect your order at Essence, Bahria Town Phase 8, using your Order ID.',
  confirm: 'We’ll confirm your order on WhatsApp. Pay when you collect.',
};

export const visit = {
  title: 'Your next favourite chocolate experience awaits',
  sub: 'in Bahria Town Phase 8.',
};

export const closing = 'Beautifully indulgent. Unforgettably delicious. Made for your sweetest moments.';

/** Longer copy for /menu (SEO). */
export const menuIntro = {
  title: 'The dessert menu',
  lead: 'Handcrafted, freshly baked, always delicious.',
  body: [
    'From our signature rich chocolate cake and fudgy chocolate brownies to creamy cheesecakes, a classic Italian tiramisu and a soft tres leches, every Essence dessert is made to turn an ordinary day into a sweet moment.',
    'Order online and collect from our patisserie in Bahria Town Phase 8, Rawalpindi. Place your order with just your phone number, then pick it up with your Order ID. It’s ready when you are.',
  ],
};

export const categoryLines: Record<string, string> = {
  'cat-chocolate': 'Rich flavours, timeless classics.',
  'cat-fruity': 'Bright flavours, pure indulgence.',
  'cat-signature': 'Classic recipes, modern touches.',
};

/** Item pages: an extra paragraph for search and a short SEO description. Keyed by product id. */
export const itemCopy: Record<string, { long: string; keywords: string }> = {
  'm-chocolate-cake': {
    long: 'Our chocolate cake is where deep, rich chocolate meets a moist, tender sponge, finished with a velvety chocolate frosting. Rich without being heavy, it is the cake for birthdays, celebrations and every moment in between. Order a slice or more online and pick it up from Essence in Bahria Town Phase 8.',
    keywords: 'rich chocolate cake Bahria Town, chocolate cake Rawalpindi',
  },
  'm-brownie': {
    long: 'Dense, fudgy and deeply chocolatey: our chocolate fudge brownie is made with rich chocolate, cocoa and butter, with just a hint of vanilla. Crisp on top and gooey in the middle, it is the brownie chocolate lovers come back for.',
    keywords: 'fudge brownie Bahria Town, best brownies Rawalpindi',
  },
  'm-og-cookies': {
    long: 'The OG cookie is a classic recipe made with premium ingredients and loaded with chocolate chips. Golden at the edges and soft in the centre, it is the simple treat that never goes out of style.',
    keywords: 'chocolate chip cookies Bahria Town, cookies Rawalpindi',
  },
  'm-lemon-tart': {
    long: 'A buttery tart shell filled with zesty lemon curd and topped with fresh cream. Bright, tangy and beautifully balanced, our lemon tart is a fresh finish to any meal.',
    keywords: 'lemon tart Bahria Town, lemon tart Rawalpindi',
  },
  'm-lemon-cake': {
    long: 'A soft vanilla sponge brightened with lemon glaze and fresh zest. Light, fragrant and perfect with an afternoon coffee.',
    keywords: 'lemon cake Bahria Town, lemon cake Rawalpindi',
  },
  'm-blueberry-cheesecake': {
    long: 'Creamy, smooth cheesecake on a buttery biscuit base, crowned with real blueberries. A fruity favourite that is as beautiful as it is delicious.',
    keywords: 'blueberry cheesecake Bahria Town, cheesecake Rawalpindi',
  },
  'm-banana-bread': {
    long: 'Made with ripe bananas and warm spices and baked to a golden finish. Moist, comforting and just sweet enough, our banana bread is a cosy treat any time of day.',
    keywords: 'banana bread Bahria Town, banana bread Rawalpindi',
  },
  'm-tres-leches': {
    long: 'A soft sponge soaked in three milks and finished with light whipped cream. Our tres leches cake is melt-in-the-mouth comfort, made for sharing with the people you love.',
    keywords: 'tres leches cake Bahria Town, tres leches Rawalpindi',
  },
  'm-tiramisu': {
    long: 'Layers of mascarpone, coffee and cocoa in the classic Italian style. Creamy, light and lifted by real coffee, our tiramisu is a grown-up dessert worth slowing down for.',
    keywords: 'tiramisu Bahria Town, tiramisu Rawalpindi',
  },
  'm-salted-caramel-cheesecake': {
    long: 'Creamy cheesecake on a crunchy biscuit base, drizzled with rich salted caramel. Sweet, salty and completely irresistible.',
    keywords: 'salted caramel cheesecake Bahria Town, cheesecake Rawalpindi',
  },
  'm-marble-cake': {
    long: 'Vanilla and chocolate sponge, beautifully swirled together. Our marble cake is a timeless classic: soft, buttery and perfect with tea or coffee.',
    keywords: 'marble cake Bahria Town, marble cake Rawalpindi',
  },
};

export const faqs = [
  {
    q: 'Do you deliver?',
    a: 'Online orders are pickup only. Place your order on the website, then collect it from Essence in Bahria Town Phase 8 with your Order ID.',
  },
  {
    q: 'Do I need an account to order?',
    a: 'No. Just add your desserts to the cart and place the order with your phone number. We send a WhatsApp confirmation with your Order ID.',
  },
  {
    q: 'How do I pay?',
    a: 'You pay at the counter when you collect your order, by cash, card or mobile wallet. GST is applied at the counter based on your payment method.',
  },
  {
    q: 'Where is Essence?',
    a: 'Essence is in Bahria Town Phase 8, Rawalpindi. Use the Directions button for the exact location.',
  },
];
