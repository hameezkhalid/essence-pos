# Essence website

The public store website for Essence (Bahria Town Phase 8): menu, cart and **pickup orders** that land in the POS.
Astro (static), vanilla TypeScript, GSAP + Lenis animations. No user accounts, no server code.

## How ordering works

1. The website shows the **same menu as the POS**. Prices, sold-out flags and the "taking orders" switch refresh live from Firestore.
2. The customer adds items to the cart and places a pickup order with their phone number.
3. The website creates `stores/essence/webOrders/{CODE}`. Security rules allow create only, with validation, and only while
   *Settings › Online orders › Take pickup orders* is on.
4. A till picks the order up, **prices it from the POS menu** (website prices are never trusted) and holds it as `web-{CODE}`,
   with a chime and a toast. It shows under **Online** / **Held orders** on the sell screen.
5. The cashier taps **WhatsApp ▾ › Order placed**. WhatsApp opens on the shop PC with the message already written; press Send.
   This uses the shop's own number and costs nothing. When the customer collects, the cashier recalls the order and charges it.

If no till has reported in for 15 minutes (shop closed, PC off), the website pauses ordering on its own.

## Commands

```bash
npm install
npm run dev            # http://localhost:4321
npm run build          # fetches the live menu into src/data/menu.json, then builds dist/
npm run build:offline  # build from the committed menu snapshot
npm run check          # type check
npm run icons          # regenerate favicons + og-image.jpg from src/assets
npm run test:rules     # Firestore rules tests on the emulator (needs Java; Android Studio's JBR works)
```

Pages: home, menu, 11 item pages, Corporate & Events (`/corporate-events`, quote form → WhatsApp), About, Contact.
Copy follows the client's brief in `reference/ESSENCE_Website_Content_Developer_Brief.docx` (no prices, no unconfirmed claims).

End-to-end tests (`npm run test:quote` needs only a preview build; the order test needs the emulator):

```bash
(cd ../essence-pos && firebase emulators:start --only firestore --project essenceisb)
PUBLIC_FIRESTORE_EMULATOR=127.0.0.1:8080 npm run build:offline && npx astro preview --port 4321
npm run test:e2e
```

## Content

- Shop details: `src/site.config.ts` (fields marked TODO are placeholders: WhatsApp, exact address, map pin, hours, Instagram, domain).
  The WhatsApp number, hours and address also come live from the POS (Settings › Online orders and Store profile).
- Copy and SEO text: `src/content/copy.ts`.
- Photos: `src/assets/menu/{productId}.jpg`. To swap in the client's high-res photos, replace the files (keep the names) and rebuild.
  The current ones are 360 px placeholders taken from the POS.
- New menu items appear after a rebuild (`npm run build`). Prices and sold-out changes show live without one.

## Deploy (only when asked)

```bash
# 1. Security rules (from essence-pos): public menu read + web order create
(cd ../essence-pos && firebase deploy --only firestore:rules)
# 2. Website: the project's default Hosting site, https://essenceisb.web.app
npm run build && firebase deploy --only hosting
```

Then in the POS: *Settings › Online orders*, add the shop WhatsApp number and switch **Take pickup orders** on.
