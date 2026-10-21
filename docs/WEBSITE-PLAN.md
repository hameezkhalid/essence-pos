# Essence Website + Online Pickup Orders

## Context
The POS has launched (Flutter, Firestore project `essenceisb`, store `essence`, an 11-item dessert menu, and an admin panel at essenceisb.web.app). The next deliverable is the public store website, which goes in `essence-website/`.

The reference site (`essence-website/reference/`, FUDG) has the right structure but no motion. The new site should be:
- lightweight, SEO-optimised and modern
- heavily animated and visual-first, with little text.

It must show the **same menu as the POS**, keep a cart without logins, and take **pickup-only** orders with a phone number. Orders must reach the POS, and the customer gets a WhatsApp message.

Decisions the user made:
- **WhatsApp:** sent with one tap from the POS. WhatsApp opens with the message already written, using the shop's own number. Free and within WhatsApp's rules.
- **Order API:** a Firestore "inbox" protected by security rules. No Cloud Functions and no Blaze plan.
- **Prices:** menu prices and a subtotal, with "GST is applied at the counter based on your payment method".
- **Photos:** use the current 360px POS photos as placeholders; the client will send high-res replacements.

All plans and docs stay local. Copy this plan to `docs/WEBSITE-PLAN.md` as the first step. Deploy only when the user asks. Never publish Artifacts.

---

## Part A: Order flow (website → Firestore → POS)

```
Website ──create──▶ stores/essence/webOrders/{CODE}   (public create-only, validated)
                     status:new
POS intake till ──listen + txn claim──▶ builds a held order  orders/web-{CODE}  (prices from POS menu)
                     webOrders/{CODE}.status → inPos / cancelled
Cashier: Held orders ▸ WEB chip ▸ [WhatsApp "placed"] ▸ Recall ▸ checkout on pickup
```

- **Order ID:** a 5-character code from an alphabet with no look-alike characters (`ABCDEFGHJKMNPQRSTUVWXYZ23456789`), shown as `#K7QX2`.
  - The website generates it.
  - If the code already exists, the create counts as an update and is denied, so the site retries with a new code.
- **The POS controls prices.** The website sends only `{productId, qty, sizeCode?, optionIds?}`. The POS rebuilds each line from its local product table.
- **A web order is marked by its id prefix `web-`.** `checkout()` keeps the held id (`pos_service.dart:113`), so the marker survives payment.
  - Don't add Drift columns: `CartState` would drop them when the order is re-held or checked out.

### A1. Firestore rules: `essence-pos/firestore.rules`
Add specific `match` blocks. These are combined with the existing member wildcard, so members keep full access.
- **Public `get, list`** on `stores/essence/{products,categories,modifierGroups}/{id}` and `stores/essence/public/{doc}`.
  - Nothing sensitive is exposed: staff, settings and FBR stay members-only.
- **Public `create`** on `stores/essence/webOrders/{code}` only when all of these hold:
  - `code.matches('^[A-HJ-NP-Z2-9]{5}$')`
  - `keys().hasOnly([...])`
  - `phone.matches('^03[0-9]{9}$')`
  - `name` is a string of 40 characters or fewer
  - `note` is 200 characters or fewer
  - `lines is list && lines.size() >= 1 && <= 30`
  - `status == 'new'`
  - `createdAt == request.time`
  - `get(public/site).data.accepting == true`
- **No public read or update.**
- **App Check is not used:** enforcing it would block the Windows tills, which have no App Check support.
- **Spam is handled by:**
  - the `accepting` switch
  - a honeypot field and a client-side cooldown on the website
  - the cashier's Discard button.

### A2. POS: new files
- **`lib/core/sync/web_order_inbox.dart`** works directly with Firestore (`FirestoreRemote.col()`, `firestore_remote.dart:13-14`). It follows the Firestore-only pattern at `lib/app/services.dart:44`. Don't widen `RemoteStore`.
  - `watchNew()`: `where status == 'new'`, sorted on the client, so no index is needed.
  - `claim(code, deviceId)`: a transaction that moves `new` to `claimed` and records `claimedBy`.
  - `markInPos(code, orderId, total)` and `markCancelled(code)`.
  - `heartbeat()`: merge-update `public/site.intakeSeenAt`. Use merge, not `writeDerived`, because that does a full set.
- **`lib/core/services/web_order_intake.dart`**
  - Runs only when Firestore is on, the device is not the admin panel, and the per-device switch **"This till receives online orders"** (LocalMeta) is on.
  - For each new doc:
    1. Claim it.
    2. Skip it if `orders/web-{code}` already exists locally.
    3. Map the lines the same way as `CartNotifier.add` (`lib/app/providers.dart:136-158`):
       - drop unknown or inactive products
       - clamp qty to 1–20
       - resolve sizes and options from local JSON
       - list sold-out items in the order note.
    4. Call `pos.hold(CartState(heldOrderId: 'web-$code', type: takeaway, customerName, customerPhone, note: 'Website pickup #CODE …'), staff: kWebStaff, shift: null, sendToBar: settings.online.sendToBar)`.
    5. Call `markInPos`.
  - On start, retry any docs still `claimed` by this device.
  - Emits an `events` stream.
  - `kWebStaff` is an in-memory `StaffMember(id:'web', name:'Website')`. Never save it.
- **`lib/features/settings/sections/online_section.dart`**, under Settings › Online orders:
  - accepting-orders toggle
  - shop WhatsApp number
  - send-to-bar toggle
  - this-till-receives toggle
  - "placed", "ready" and "cancelled" templates using `{name} {code} {items} {total}`. The default "placed" template says the final bill includes GST at the counter.
  - On save, it publishes `public/site`: accepting, WhatsApp number, address and hours from `store` settings.

### A3. POS: edits
- **`lib/core/models/settings_models.dart`:** add `OnlineOrderSettings` and `SettingKeys.online`, and wire it into `fromMaps`/`toMaps` (lines 399-414).
- **`lib/app/services.dart`:**
  - Create, start and dispose the intake service.
  - Call `inbox.heartbeat()` from `beat()` (line 89).
  - Publish `public/site` when the intake till starts.
- **`lib/features/sell/sell_dialogs.dart:391-475` (`_HeldOrders`):**
  - WEB chip with the large `#CODE`
  - a search-by-code field
  - phone number
  - **WhatsApp ▾** button with the Placed, Ready and Cancelled templates. It uses `url_launcher` to open `https://wa.me/92XXXXXXXXXX?text=…`; convert `03…` to `92…`.
  - Discarding a web order also calls `inbox.markCancelled`.
- **`lib/features/sell/sell_screen.dart:198-245`:** a separate "Online" badge showing the count of held orders whose id starts with `web-`.
- **`lib/features/shell/app_shell.dart:71-99`:**
  - subscribe to intake events
  - show `toast()` (`lib/shared/common.dart:225`) with "New online order #CODE · Rs X" and a **View** action that opens Held orders
  - play a chime.
- **`pubspec.yaml`:**
  - add `url_launcher`, `audioplayers` and `assets/sounds/chime.mp3`
  - add the Android `<queries>` VIEW/https intent in `android/app/src/main/AndroidManifest.xml`.
- **Reports** can tag online sales with `id LIKE 'web-%'`. This is optional: an "Online" figure on the dashboard.

---

## Part B: Website (`essence-website/`)

### Stack (lightweight, static, SEO-first)
- **Astro 5** with static output. Interactive parts are vanilla TypeScript islands, with no React, so the JS payload stays small.
- **GSAP + ScrollTrigger** (now free) and **Lenis** smooth scroll for motion. Everything respects `prefers-reduced-motion`.
- **CSS View Transitions** between pages.
- **`astro:assets`** for responsive AVIF/WebP, lazy-loaded with fixed dimensions to avoid layout shift.
- **Fonts:** Playfair Display and Inter, matching the POS, plus one script accent font for "Sweet moments", taken from the printed menu. All self-hosted through `@fontsource`.
- **Firestore over REST,** without the Firebase SDK:
  - **At build time**, a script fetches categories, products and modifierGroups into `src/data/menu.json`, so the menu is in the static HTML for SEO. If the fetch fails, it falls back to the committed snapshot.
  - **At run time,** a small fetch refreshes prices, availability (sold out) and `public/site.accepting`.
  - **Orders** are sent by `POST …/documents/stores/essence/webOrders?documentId=CODE`.
- **Palette:** POS tokens (`essence-pos/lib/app/theme/tokens.dart:73-127`):
  - olive `#4E5726`
  - cream `#F9F5EC`
  - beige `#EDE3CF`
  - coffee `#8A5A36`
  - text `#2B2118`
  - plus a deep chocolate shade for the hero sections.
- **Visual motifs:** olive-leaf line art drawn in with SVG stroke animation, and the arched image frames from the printed menu (`docs/dessert-menu.jpg`).
- **Hosting:** a new Firebase Hosting site `essence-web` (`essence-website/firebase.json` and `.firebaserc`, project `essenceisb`). The custom domain is attached later.

### Structure
- **`src/site.config.ts`:** one place for the name, address (Bahria Town Phase 8, Rawalpindi), WhatsApp number, Instagram, hours, map link and domain. These are placeholders until the client confirms them.
- **`src/data/menu.json`:** the snapshot.
- **Images:** `src/assets/menu/{productId}.jpg`, copied from `essence-pos/assets/images/menu/`. Each photo is mapped by product id, with a styled fallback.
  - Large hero use gets a soft blur-up treatment.
  - Swapping in high-res photos later is a file replacement and nothing else.
- **`scripts/fetch-menu.mjs`:** the build-time fetch.
- **Pages:**
  - `/` home
  - `/menu` the full menu
  - `/menu/[slug]` 11 item pages, for long-tail SEO
  - `/visit`, or a section on home
  - `404`
- **Components:**
  - `Nav`, with the cart button and a count bump animation
  - `Hero`, `Marquee`, `ProductCard`, `CategoryTabs`, `ProductSheet` (sizes and options)
  - `CartDrawer`
  - `PickupBanner`
  - `Checkout`
  - `OrderSuccess`
  - `Footer`
- **`src/lib/`:**
  - `cart.ts`: a store in localStorage
  - `firestore.ts`: REST helpers
  - `order.ts`: code generator, retry, phone normalisation
  - `motion.ts`: GSAP and Lenis setup

### Home page sections (visual-first, little text)
1. **Hero:**
   - Full-bleed chocolate-cake image with parallax.
   - The headline "Beautifully indulgent." is revealed word by word.
   - The sub-line is "Unforgettably delicious. Made for your sweetest moments."
   - Two CTAs: **Order for pickup** and **View menu**.
2. **Marquee:** "Belgian Chocolate · Freshly Baked · Bahria Town Phase 8 · Pickup in minutes".
3. **Signature: Belgian chocolate cakes.** A pinned scroll story where the image scales and the client's copy appears in three short beats.
4. **Menu preview:** category tabs (Chocolate Favourites, Fresh & Fruity, Signature Desserts), staggered card reveals, and **+ Add** buttons that fly into the cart.
5. **Made for your sweetest moments:** a celebrations, loved ones, treat-yourself image mosaic with hover tilt.
6. **How pickup works:** three animated steps: add to cart → place with your phone → collect with your Order ID.
7. **Visit us:** address, hours, a lazy-loaded map, plus WhatsApp and Directions buttons.
8. **Instagram strip** and the footer.

### Cart and checkout
- The cart drawer always shows a **Pickup order** banner: "Pickup only. Collect your order at Essence, Bahria Town Phase 8, using your Order ID."
- It shows the subtotal and "GST is applied at the counter based on your payment method".
- **Checkout** takes:
  - phone (required, `03XXXXXXXXX`, with an input mask)
  - name (optional)
  - note (optional)
  - a hidden honeypot field.
- **On submit:**
  1. Generate the code.
  2. Send the REST create, retrying up to 3 times on `permission-denied` for a code collision.
  3. Show the success screen.
- **The success screen** has:
  - a large `#CODE` with confetti or a chocolate-drip animation
  - "We'll send a WhatsApp confirmation shortly"
  - a **Message us on WhatsApp** button, linking `wa.me/{shop}` with the Order ID already filled in
  - the last order saved in localStorage.
- **When `accepting` is false** (or the intake heartbeat is more than 10 minutes old), the site shows "Online ordering is paused, visit us in store" and checkout is turned off.

### SEO
- Each page gets its own title, meta and canonical tags, plus OpenGraph and Twitter tags with a 1200×630 OG image. Example titles:
  - "Essence | Belgian Chocolate Cakes & Desserts in Bahria Town Phase 8"
  - "Chocolate Cake in Bahria Town Phase 8 | Essence"
- **JSON-LD:**
  - `Bakery`/`CafeOrCoffeeShop` LocalBusiness (address, geo, hours, `hasMenu`)
  - a `Menu` with `MenuSection` and `MenuItem` entries and `offers` in PKR
  - `BreadcrumbList` on item pages.
- `@astrojs/sitemap`, `robots.txt`, `site.webmanifest`, favicons generated from `assets/essence_logo_hd.png`, and `lang="en-PK"`.
- **Copy:** I'll write SEO copy from the client's text in `src/content/copy.ts`. Key phrases:
  - "Belgian chocolate cake Bahria Town"
  - "desserts in Bahria Town Phase 8 Rawalpindi"
  - "cakes near me Bahria Town"
  - "patisserie Islamabad Rawalpindi"
  - "cake pickup".

  It stays short and punchy on screen. The longer SEO paragraphs go on `/menu` and the item pages.
- **Performance targets:** Lighthouse 95+ on mobile for performance and SEO. The LCP hero image is preloaded with `fetchpriority=high`, and less than 60 KB of JS is gzipped.

---

## Inputs needed from the client (placeholders until then)
- shop WhatsApp number
- exact address, map pin and opening hours
- Instagram handle
- domain
- high-res photos (1600px or larger, ideally one hero shot of a Belgian chocolate cake)

---

## Verification
1. **Rules:** run Firestore emulator tests (`essence-website/tests/rules.test.ts`, using `@firebase/rules-unit-testing`). They check that:
   - anonymous users can read products but not settings or staff
   - a valid `webOrders` create is allowed; bad phone, extra keys, an oversized lines list, an update and a read are all denied
   - creates are denied when `accepting` is false.
2. **POS:** `flutter test`, adding to `test/services_test.dart`:
   - line mapping (unknown, inactive, sold-out and size cases)
   - the "already exists locally" skip
   - the `web-` badge filter.
   - Then `flutter analyze`.
3. **End to end on the emulators:**
   - Run the website (`npm run dev`) against the emulator and place an order.
   - Run the macOS POS against the emulator. Check for the toast and chime, the WEB held order with the right POS prices, and that the WhatsApp button opens the prefilled message.
   - Recall and check out, then check that the order is paid with id `web-CODE`.
4. **Website:**
   - `npm run build`
   - Lighthouse on mobile
   - check the JSON-LD in Google's Rich Results Test
   - try the cart, reduced motion and phone width (375px).
5. **Deploy, only when the user asks:** `firebase deploy --only firestore:rules` from `essence-pos/`, `firebase deploy --only hosting:essence-web` from `essence-website/`, and a new Windows build through Actions.

---

## Status (2026-10-21): built, not deployed

- **POS** (`essence-pos/`):
  - Settings › Online orders
  - web order intake (`lib/core/services/web_order_intake.dart`, `lib/core/sync/web_order_inbox.dart`)
  - Online badge, WEB held orders with WhatsApp templates, chime and toast
  - public rules in `firestore.rules`
  - Tests: `flutter test` 29/29.
- **Website** (`essence-website/`): Astro site with home, menu, 11 item pages and a 404; cart and pickup checkout; live prices, sold-out flags and the ordering switch; SEO (JSON-LD, sitemap, OG image).
  - Rules tests: 20/20 on the emulator.
  - Browser end-to-end order test passes.
  - Lighthouse mobile: performance 94–95, accessibility 100, SEO 100.
- **Still to do:**
  - deploy the rules, website and admin panel, and run a new Windows build (when asked)
  - fill the TODO placeholders in `essence-website/src/site.config.ts`
  - swap in hi-res photos.

**Hosting change (2026-10-21, user decision):** the website takes the default site, https://essenceisb.web.app. The admin panel moves to a new site, https://essenceisb-admin.web.app (`essence-pos/firebase.json`: `"site": "essenceisb-admin"`; `essence-admin` was taken globally). Credit "Powered by Nibnox (SMC-Private) Ltd." (links to nibnox.com) added to the website footer and the POS receipt.
