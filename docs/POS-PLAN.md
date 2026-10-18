# Essence POS — Build Plan (Basic Variant, Demo Phase)

> Café: **Essence — Patisserie · Coffee · Moments** (Islamabad / Rawalpindi)
> Owner's company (billing entity): **Mix & Match Collection**, attn. Hamza Asif (see `docs/invoice-00172.html`, `invoice-00173.html`)
> Source of truth: `docs/coffee-pos.html` (NIBNOX Brew OS proposal → "The Basic Variant · Week 1")
> Tax authority: **FBR**
> Status: **Demo build complete (2026-10-16)** — app in `essence-pos/` (see its README.md). Phases 0–7 implemented; FBR is simulated, menu is demo data.

---

## 1. What we are building

### 1.1 Scope of the Basic variant (from proposal + confirmed-scope invoice)

| Area | In the demo build | Notes |
|---|---|---|
| Basic POS | ✅ Full | Billing, sales, receipts |
| Offline-first | ✅ Full | Sells with no internet, syncs in order, no duplicates |
| Real-time | ✅ Full | Every screen updates live, no reload |
| Basic inventory | ✅ Full | Stock deducted with each sale, low-stock alerts, stock-in/adjustments |
| Receipt printer | ✅ Full | 80mm ESC/POS thermal, KOT (bar ticket), cash drawer kick |
| FBR integration | 🟡 **Architecture + mock** | Real adapter added after demo (needs client's FBR POS ID/token) |
| Real menu | 🟡 **Dummy menu** | Swapped for the real menu after demo |
| Owner live dashboard | ✅ Web build | Same app, served from Firebase Hosting |
| Store website (WhatsApp ordering) | ⏭ Next project | After the POS |

**Proposal "Also included in the Core" checklist, all covered:** Menu & modifiers · Split payments · Discounts & voids · Staff roles · Shift & Z-reports · Receipt & KOT print · Cash drawer · Hold / park orders · Returns & refunds · Customer lookup · Multi-device · Daily backups.

**Explicitly NOT in this build (paid add-on modules in the proposal):** QR self-ordering, waiter app, online ordering, customer mobile apps, loyalty, Google reviews, KDS barista display, multi-branch insights, expenses & finance, auto purchase orders to suppliers.

---

## 2. Recommended tech stack

### 2.1 Verdict: your instinct is right — Flutter + Firebase — with one important change

**Keep:** Flutter (Windows desktop) + Firebase (Auth, Firestore, Hosting) + SQLite.

**Change:** don't rely on Firestore's built-in offline cache as the "offline-first" layer. Make **local SQLite the source of truth** on each terminal, and run our own **sync engine** (outbox → Firestore, Firestore listeners → local). Reasons:

- Firestore's offline cache is a *cache*, not a database. It isn't designed for days of offline selling, offline reporting queries, or guaranteed per-device invoice numbering.
- FlutterFire's Windows support is built on the Firebase C++ SDK and is younger than the mobile/web plugins (Windows is listed on pub.dev for `cloud_firestore` 7.0.0). If the POS only *talks* to Firestore through our sync engine, a Windows plugin issue can never stop a sale, and we can swap the transport (e.g. Firestore REST) without touching the app.
- SQLite gives us fast SQL aggregates for Z-reports, stock levels and sales by hour, even offline.

### 2.2 Stack table

| Layer | Choice | Why |
|---|---|---|
| App framework | **Flutter 3.47** (installed) | One codebase → Windows desktop (primary), Android tablet (optional second terminal), Web (owner dashboard). Excellent touch UI, 60fps. |
| Language | Dart 3.13 | — |
| State management | **Riverpod 3** (+ code-gen) | Stream-friendly, testable, no BuildContext coupling |
| Local database | **Drift (SQLite)** | Typed SQL, migrations, **reactive `.watch()` streams** → UI updates instantly even offline. Runs on Windows, Android, and Web (WASM). |
| Cloud database | **Cloud Firestore** | Real-time snapshot streams across devices and the owner dashboard |
| Auth | **Firebase Auth** (store/device account) + **local staff PINs** | Device signs in once; cashiers switch with a 4-digit PIN that works offline |
| Server logic | Cloud Functions (later, optional) | Backstop for FBR retries, daily backup export. Needs the Blaze plan; not required for the demo. |
| Hosting | **Firebase Hosting** | Owner dashboard (Flutter web build); later the website |
| Local dev | **Firebase Emulator Suite** | All development runs on this machine; no cloud project needed until we choose to deploy |
| Routing | go_router | Deep links for the web dashboard |
| Models | freezed + json_serializable | Immutable models, safe serialization |
| IDs | UUID v7 (client-generated, time-ordered) | Makes offline writes idempotent → no duplicates on sync |
| Printing | esc_pos_utils_plus (bytes) + our own transports | LAN (TCP 9100), Windows USB via the RAW spooler (`win32`), Bluetooth on Android later |
| Charts | fl_chart | Sales by hour, payment mix |
| Connectivity | connectivity_plus + a real reachability check | Network adapter "up" ≠ internet |
| Windows packaging | MSIX (`msix` package) or Inno Setup installer | Clean install/update on the shop PC |
| Fonts | Bundled as assets (not fetched at runtime) | Must work offline |

### 2.3 Alternatives considered (and why not)

| Option | Verdict |
|---|---|
| **Tauri + React** | Light installer, web skills reuse, but thermal printing and offline DB plumbing move into Rust; two languages for a small team. Good, but Flutter fits better here. |
| **Electron + React** | Heavy (150MB+, RAM-hungry), poor on low-end shop PCs. |
| **.NET (WPF/MAUI)** | Great on Windows, but weak Firebase support and no free web dashboard. |
| **Supabase + PowerSync** | Strongest off-the-shelf offline-first sync (Postgres + SQLite) and worth knowing about, but you prefer Firebase, and our outbox design covers what we need. |
| **Isar / Hive / ObjectBox** instead of Drift | Isar's maintenance is uncertain, Hive isn't relational (weak for reports), ObjectBox sync is commercial. Drift wins. |

> **Website note (for later):** the store website needs SEO, and Flutter web isn't good at it. When we get there I'd suggest **Next.js or Astro**, sharing the same Firestore menu data, on Firebase Hosting.

---

## 3. Architecture

### 3.1 Data flow

```
             ┌────────────────────── POS Terminal (Windows) ───────────────────────┐
  Cashier →  │  UI (Flutter)  ⇄  Riverpod  ⇄  Repositories  ⇄  Drift (SQLite)       │
             │        ▲                                   │  ▲                       │
             │        └──── .watch() streams (instant) ───┘  │                       │
             │                                           Outbox table               │
             │                                    ┌──────────┴──────────┐           │
             │                                Sync Engine          Fiscal Queue      │
             │                                (push/pull)          (FBR adapter)     │
             │   Printer service (ESC/POS) ── USB / LAN ── 80mm printer + drawer     │
             └──────────────┬─────────────────────────────────────────┬────────────┘
                            │ when online                             │ when online
                            ▼                                         ▼
                 Cloud Firestore  ── snapshot streams ──►  Owner dashboard (Web, Hosting)
                            │                              Other terminals / tablets
                            ▼
                     (later) Cloud Functions: backups, FBR retry backstop
```

### 3.2 Rules that make offline-first safe

1. **The UI reads only from local SQLite.** A sale never waits on the network.
2. **Every write goes to SQLite and the Outbox in one transaction.**
3. **Sync engine** pushes the Outbox to Firestore in order, with exponential backoff. Each push is an idempotent `set(id)`, so retries can't duplicate.
4. **Pull:** Firestore listeners (catalog, settings, stock, other terminals' orders) upsert into SQLite, so the UI updates automatically.
5. **Conflict strategy by data type:**
   - *Orders, payments, refunds, stock movements, shift events, audit log* → **append-only, immutable**, so there are no conflicts.
   - *Menu, prices, settings, staff* → **last-write-wins** by `updatedAt` (edited rarely, usually from one place).
   - *Stock levels* are **never edited directly**. Stock = sum of movements (sale −, stock-in +, adjustment ±). Two offline terminals can't overwrite each other.
6. **Invoice numbers work offline:** `ESS-{terminal}-{sequence}` (e.g. `ESS-T1-000482`), plus a daily **order token** (#001…) for calling orders.
7. **Status always visible:** Online/Offline pill, "N to sync" badge, last-synced time, and FBR status per invoice.

### 3.3 FBR integration (structure now, real later)

- `FiscalAdapter` interface: `submit(invoice) → FiscalResult { fiscalInvoiceNo, qrPayload, status }`.
- **Demo:** `MockFbrAdapter`. It returns realistic invoice numbers after a short delay, queues while offline, and fills them in when back online, the same flow the proposal's simulator shows.
- **Later:** `FbrImsAdapter` (FBR POS integration API: POS ID + token, sandbox/live). Any other authority would be another adapter behind the same interface, so nothing else changes.
- **Separate fiscal queue** from the data sync. Each invoice has a status: `pending → reported | failed`.
- **Receipt:** FBR invoice # + QR code + FBR POS fee line (Rs 1, configurable). If offline, it prints "FBR invoice queued", with a one-tap reprint once reported.

### 3.4 Tax engine (fully configurable from Settings)

The tax rate depends on **how the customer pays**, so tax is calculated per payment, not per cart.

- **GST is built in and fixed:** the name "GST" can't be changed or deleted. There's an **Enable GST** toggle.
- **GST rates are custom values,** one per rate group: **Cash** and **Card / Online**. Every payment method maps to one of these groups. **Defaults: Cash 15%, Card / Online 5%.** There are no presets; the owner types the numbers.
- **Other taxes:** the owner can add extra taxes alongside GST, each with its own name, Cash % and Card/Online %, and an enable toggle. Each one appears as its own line on the bill.
- **Prices inclusive or exclusive of tax**, set by a toggle:
  - *Exclusive:* menu prices are before tax. Tax is added on top at the paid method's rate. The payment screen shows the total for each method ("Cash Rs 1,150 · Card Rs 1,050"), so the cashier can tell the customer.
  - *Inclusive:* menu prices already contain tax, and **the bill total equals the menu prices**. The bill still shows the tax that's inside the total, at the same percentage as the payment method, e.g.:

    ```
    2× Cappuccino                 1,300
    1× Butter Croissant             550
    ---------------------------------
    TOTAL (Cash)               Rs 1,850
      incl. GST 15%                241
      Net of tax                 1,609
    ```

    Here the tax is extracted, not added: tax = total × rate ÷ (100 + rate). If the customer pays by card, the same bill shows "incl. GST 5%: 88" with the total still Rs 1,850. The same breakdown goes to FBR.
- **Split payments** with different rates: each payment portion is taxed at its own rate. For example, Rs 500 cash at 15% plus the rest on card at 5%. The receipt and FBR invoice show the breakdown.
- **Per-category / per-product exemption:** a product or category can be marked tax-exempt (e.g. retail packaged items).
- **Other charges** (each configurable on/off and by amount):
  - FBR POS fee: fixed Rs 1.
  - Service charge: %, can be limited to dine-in only, and can be taxable or not.
  - Delivery charge: fixed.
- **Rounding:** none / nearest Rs 1 / nearest Rs 5 / nearest Rs 10.
- All money is stored as **integer paisa**, never floats. The engine is pure Dart with full unit tests for every combination above.

### 3.5 Receipt printing

- 80mm ESC/POS thermal printers, the common type in Pakistan (Epson TM-T82/T88, Black Copper, etc.). The model is decided later.
- **USB on Windows is the primary transport.** It sends raw bytes through the Windows print spooler (Win32 `WritePrinter`), so it works with whatever driver the printer installs, and we don't depend on a specific model. LAN (raw TCP 9100) is a secondary option. Bluetooth for Android comes later.
- Paper width (58mm / 80mm) and characters per line are configurable, in case the chosen printer differs.
- Documents: Customer receipt, **KOT / bar ticket** (items + modifiers + notes, no prices), shift X/Z report, reprint.
- QR code printed natively (ESC/POS `GS ( k`), with a raster-image fallback for printers that don't support it.
- Logo printed as a raster image in the receipt header.
- Cash drawer kick through the printer port (ESC p) on cash payment or "No sale" (permission-gated).
- Printers settings screen: add a printer, test print, choose which documents go to which printer.
- Without a printer attached (demo/dev), there's an on-screen receipt preview identical to the printed layout.

---

## 4. Data model

Firestore path: `/stores/{storeId}/…`. Local SQLite mirrors the same tables, plus `outbox` and `sync_state`.

| Collection | Key fields |
|---|---|
| `categories` | name, icon, sortOrder, active |
| `products` | name, categoryId, basePrice, image, sizes[] {S/M/L, priceDelta}, modifierGroupIds[], taxExempt, active, updatedAt |
| `modifierGroups` | name (Milk, Extra shot, Syrup…), min/max select, options[] {name, priceDelta, stockItemId?} |
| `taxes` | id (`gst` is built-in and fixed), name, enabled, cashRate (GST default 15), cardOnlineRate (GST default 5), sortOrder |
| `paymentMethods` | name (Cash, Card, JazzCash, Easypaisa, Bank transfer, Raast…), rateGroup (cash / cardOnline), opensDrawer, active, sortOrder |
| `charges` | type (fbrFee/service/delivery), mode (fixed/%), value, orderTypes[], taxable, enabled |
| `areas` / `tables` | area name (Ground, Upstairs, Outdoor); table label, seats, active |
| `staff` | name, role (owner/manager/cashier), pinHash, active |
| `devices` | name, code (T1), printer config, lastSeen |
| `shifts` | deviceId, openedBy, openingFloat, cashIn/out[], countedCash, expectedCash, closedAt |
| `orders` | number, token, type (dine-in/takeaway/delivery), table?, guests?, delivery {name, phone, address}?, lines[] (snapshot of name/price/modifiers), discounts[], charges[], subtotal, taxLines[] (per payment portion: method, rate, base, tax), total, payments[] (method, rateGroup, amount, tendered, change), customerId?, status (held/paid/voided/refunded), shiftId, staffId, deviceId, fiscal {status, invoiceNo, qr}, createdAt |
| `refunds` | orderId, lines[], amount, reason, approvedBy |
| `customers` | name, phone, notes, visitCount, totalSpent |
| `stockItems` | name, unit (g/ml/pcs), reorderLevel, costPerUnit, currentQty (cached) |
| `recipes` | productId, size?, ingredients[] {stockItemId, qty} |
| `stockMovements` | stockItemId, qty (±), type (sale/stock-in/wastage/count), refId, note, staffId, createdAt |
| `settings` | store profile, pricing mode (inclusive/exclusive), rounding, enabled order types, discount limits, receipt layout, FBR config, theme (see §5.4) |
| `auditLog` | action (void, discount, refund, drawer-open, price-change), staffId, approvedBy, details |

---

## 5. Screens and features

### 5.1 POS terminal (Windows, touch-first)

1. **Lock / PIN screen.** Staff avatars, 4-digit PIN, shows the current shift.
2. **Sell screen** (the main one):
   - Left: category tabs, then product grid (image/icon, name, price), search, favourites row.
   - Right: current order. Lines with size & modifiers, notes, qty ±, line/order discount, customer attach (phone lookup).
   - **Order type** switch (only the types enabled in Settings are shown):
     - *Dine-in:* table picker (by area) and guest count.
     - *Takeaway.*
     - *Delivery:* customer name, phone, address and delivery charge. This covers phone/WhatsApp orders.
   - Totals: subtotal, discount, service/delivery charge, tax, FBR fee, total. In exclusive-price mode, it shows a cash vs card/online total preview.
   - Actions: **Hold**, **Recall held**, **Clear**, **Charge**.
   - Top bar: store, terminal, cashier, online/offline + "to sync" badge, clock, theme toggle.
3. **Modifier sheet.** Size (S/M/L), milk (regular/oat/almond), extra shot, syrups, sugar level, notes.
4. **Payment.**
   - Every payment method from Settings is shown, with its tax rate visible (e.g. "Cash · GST 15%", "Card · GST 5%").
   - Cash has quick-tender buttons (exact, 500, 1000, 5000) plus a keypad that shows the change due.
   - The order can be **split** across methods, with tax recalculated per portion live.
5. **Receipt.** Success screen + print/reprint + new order. KOT is sent automatically.
6. **Orders.** Today's and history, search by number/token, view, reprint, **refund** (full/partial, manager PIN), **void** (manager PIN + reason).
7. **Shift.** Open with opening float, cash in/out with reason, **X-report** (mid-shift), **close shift** (count cash → over/short), **Z-report** printed + saved.
8. **Inventory.** Stock list with level bars and OK/Low/Critical badges, **stock-in** (receive delivery), **adjust** (wastage/count) with reason, movement history, recipe editor per product/size, stock value. Low-stock toast when a sale crosses the reorder level.
9. **Reports / dashboard.** Today vs yesterday: gross sales, orders, avg ticket, tax collected, sales by hour, payment mix, top items, invoices with FBR status, date-range filter, export CSV/PDF.
10. **Settings (owner).** Full spec in §5.4.

### 5.2 Owner live dashboard (Web on Firebase Hosting, also works on phone)

Live today's sales, orders, tax, live order feed (with FBR status), low-stock list, terminals online/offline. Pure Firestore streams, so no reload, ever.

### 5.3 Roles & permissions

| Action | Cashier | Manager | Owner |
|---|---|---|---|
| Sell, hold, print | ✅ | ✅ | ✅ |
| Discount > limit, void, refund, no-sale drawer | needs manager PIN | ✅ | ✅ |
| Close shift / Z-report | ❌ | ✅ | ✅ |
| Inventory adjust / stock-in | ❌ | ✅ | ✅ |
| Menu, prices, staff, tax, settings | ❌ | ❌ | ✅ |

These are the defaults; the owner can edit the matrix in Settings. Every override is written to the audit log.

### 5.4 Settings panel

Every business rule lives here; nothing is hard-coded. Changes sync live to all terminals.

| Section | What's configurable |
|---|---|
| **Store profile** | Café name, logo, address, phone, NTN, STRN, owner company (Mix & Match Collection) |
| **Tax** | **Enable GST** toggle; GST **Cash %** and **Card/Online %** (custom, defaults 15 / 5); add/edit/remove **Other taxes** (name, Cash %, Card/Online %, enabled); prices inclusive/exclusive; per-category/product exemption; rounding rule |
| **Payment methods** | Add/rename/disable (Cash, Card, JazzCash, Easypaisa, Bank transfer, Raast…), map each to the Cash or Card/Online rate group, opens cash drawer yes/no, display order |
| **Order types** | Enable/disable Dine-in, Takeaway, Delivery; default type; require table for dine-in; require phone for delivery |
| **Tables** | Areas and tables (label, seats), on/off |
| **Charges** | Service charge (%, dine-in only?, taxable?), delivery charge (fixed), FBR POS fee (Rs 1, on/off) |
| **Discounts** | Preset discounts (% or Rs), cashier max discount % before a manager PIN is needed, require reason |
| **Menu** | Categories, products, prices, sizes, modifier groups, images, availability (86 an item) |
| **Staff & roles** | Staff, PINs, roles; permission matrix editable per role |
| **Receipt** | Header/footer text, logo on/off, show tax breakdown, show cashier/table/token, language-ready, number of copies |
| **Printers** | Add USB/LAN printer, paper width 58/80mm, test print, route receipt/KOT/reports, cash drawer on/off |
| **FBR** | POS ID, token, sandbox/live, enable/disable (placeholder in the demo, mock active) |
| **Terminals** | Terminal name/code (T1, T2), invoice number prefix |
| **Appearance** | Light / Dark / System theme, product grid density |
| **Data** | Load/reset demo data, export data, last backup/sync info |

### 5.5 "Modern POS" qualities we'll build in

Two taps to sell a drink · keyboard shortcuts on desktop (F-keys, Enter = charge, Esc = back) · barcode-scanner-ready search field · large touch targets (≥48px) · optimistic, instant UI · undo snackbars · empty/loading/error states everywhere · light/dark/system theme · works at 1366×768 (common budget touchscreens) up to 1920×1080 and on 10" Android tablets.

---

## 6. Design system

### 6.1 Palette (from the logo: olive `#4E5726` on cream `#F9F5EC`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `primary` (olive) | `#4E5726` | `#A3AE6E` | Primary buttons, active tab, brand |
| `primaryContainer` | `#E4E7CF` | `#3A4119` | Selected chips, highlights |
| `onPrimary` | `#FFFFFF` | `#1A1C0E` | Text on primary |
| `background` (off-white) | `#F9F5EC` | `#15130F` | App background |
| `surface` | `#FFFDF8` | `#1F1C17` | Cards, panels |
| `surfaceVariant` (beige) | `#EDE3CF` | `#2A261F` | Product tiles, cart panel |
| `accent` (brown) | `#8A5A36` | `#C99366` | Prices, secondary actions, coffee touches |
| `text` (espresso) | `#2B2118` | `#EFE8DA` | Primary text |
| `textMuted` | `#6F6556` | `#A69C8B` | Secondary text |
| `border` | `#E2D8C3` | `#3A342B` | Dividers |
| `success` | `#3E7D4F` | `#7BC28E` | Paid, synced, FBR reported |
| `warning` | `#B7791F` | `#E3B25A` | Low stock, queued |
| `danger` | `#B3473A` | `#E58C7F` | Void, critical stock, offline |

All text/background pairs will be checked for WCAG AA contrast. Implemented as a Flutter `ThemeExtension` (`EssenceColors`) on top of Material 3 `ColorScheme`, with no hard-coded colors in widgets.

### 6.2 Typography

- **Brand / headings:** an elegant serif matching the logo (*Playfair Display* or *Cormorant Garamond*), used sparingly: store name, screen titles, receipt success.
- **UI / numbers:** *Inter* with **tabular figures**, so prices line up.
- Bundled locally (offline).

### 6.3 Feel

Calm, premium patisserie aesthetic. Generous spacing, 16–20px rounded corners, soft shadows in light mode, tonal surfaces in dark mode, subtle micro-animations (item added to cart, payment success). The leaf mark from the logo is used as the app icon and empty-state motif.

---

## 7. Dummy data (demo)

Themed for a patisserie café, so it feels real in the demo:

- **Categories (6):** Hot Coffee · Iced Coffee · Tea & More · Patisserie · Cakes & Desserts · Savoury
- **~35 products** with PKR prices, e.g. Espresso, Cappuccino, Spanish Latte, Iced Caramel Latte, Matcha Latte, Butter Croissant, Pain au Chocolat, Almond Croissant, Éclair, Macarons (box of 6), Basque Cheesecake, Lotus Cheesecake, Tiramisu, Chicken Croissant Sandwich, Quiche…
- **Modifiers:** sizes, milk options (+Rs), extra shot, syrups, sugar level
- **~20 stock items** (beans, milk, oat milk, cups, lids, syrups, butter, flour, cream cheese, chocolate…) with **recipes** for every product
- **3 staff:** Owner (PIN 1111), Manager (2222), Cashier (3333)
- **Tax:** GST enabled at the defaults, 15% cash / 5% card-online, exclusive pricing (one toggle switches to inclusive for the demo)
- **Payment methods:** Cash · Card · JazzCash · Easypaisa · Bank transfer
- **Tables:** 2 areas (Ground floor, Terrace), 12 tables; all three order types enabled; service charge set up but off by default
- **30 days of generated order history** (realistic hourly curve, payment mix), so reports and charts look alive
- Store profile: "Essence", placeholder NTN/STRN, logo on the receipt

Seeding: an in-app **"Load demo data / Reset demo"** action (owner only), plus a seed script for the Firestore emulator.

---

## 8. Project structure

```
essence-coffee/
├── docs/                      # proposal, invoices, logo, this plan
├── essence-pos/               # Flutter app (Windows + Android + Web)
│   ├── lib/
│   │   ├── main.dart / bootstrap.dart
│   │   ├── app/               # router, theme (tokens, light/dark), localization-ready
│   │   ├── core/
│   │   │   ├── db/            # Drift schema, DAOs, migrations
│   │   │   ├── sync/          # outbox, push/pull engine, connectivity
│   │   │   ├── fiscal/        # FiscalAdapter, MockFbrAdapter, fiscal queue
│   │   │   ├── printing/      # ESC/POS builders, transports, templates
│   │   │   ├── money/         # paisa math, tax engine
│   │   │   └── firebase/      # init, emulator wiring
│   │   ├── features/
│   │   │   ├── auth/  sell/  payment/  orders/  shifts/
│   │   │   ├── inventory/  reports/  dashboard/  settings/
│   │   └── shared/widgets/    # buttons, tiles, keypad, status pill…
│   ├── assets/ (fonts, logo, images)
│   ├── test/                  # tax engine, sync, inventory deduction, widget tests
│   └── tool/seed/             # demo data generator
├── firebase.json / firestore.rules / firestore.indexes.json
└── essence-website/           # next project
```

Each feature: `data/` (repositories) · `domain/` (models, logic) · `presentation/` (screens, widgets, providers).

---

## 9. Delivery phases

| # | Phase | Output | Done when |
|---|---|---|---|
| 0 | **Foundation & spikes** | Flutter project (Windows/Android/Web), theme tokens light/dark, fonts, Drift schema, Riverpod, router, Firebase emulators wired. **Spikes:** Firestore streams on Windows; test print on a thermal printer. | App launches on Windows with both themes; spikes pass |
| 1 | **Selling core** | PIN login, sell screen, modifiers, cart, all 3 order types + tables, **tax engine (cash vs card/online rates, split, inclusive/exclusive) with unit tests**, payments, on-screen receipt, hold/recall, order list, Settings: tax, payment methods, order types, tables, charges | A full sale works end-to-end offline; tax is correct for every rate, split and inclusive/exclusive combination |
| 2 | **Sync & real-time** | Outbox, push/pull, listeners, status pill, multi-terminal | Two terminals + dashboard update live; pull the network, sell, reconnect: no loss, no duplicates |
| 3 | **Printing & hardware** | Receipt, KOT, reports printing, drawer kick, printer settings | Prints on a USB thermal printer on Windows (LAN as a bonus) |
| 4 | **Control & shifts** | Discounts, voids, refunds, manager overrides, roles, audit, shifts, X/Z reports | Shift closes with correct over/short |
| 5 | **Inventory** | Stock items, recipes, auto-deduction, stock-in, adjustments, alerts | Sales deduct stock correctly, including sizes/modifiers |
| 6 | **Reports & owner dashboard** | Reports screen, exports, web dashboard | Dashboard runs locally (emulator) with live data |
| 7 | **Mock FBR + demo polish** | MockFbrAdapter, FBR fields on receipt + QR, demo data, Windows installer | Demo walkthrough script runs cleanly |
| — | *After demo* | Real FBR adapter, real menu, Firebase project + Hosting deploy, then the website | — |

All work stays on this machine: local git repo, Firebase **emulators** for development. Creating the real Firebase project and deploying to Hosting happen **only when you ask**.

---

## 10. Risks

| Risk | Mitigation |
|---|---|
| FlutterFire on Windows less mature than mobile/web | SQLite is the source of truth; Firestore only behind the sync engine; Phase 0 spike; REST fallback transport |
| Tax rates change by budget/notification | All rates are settings, not code |
| Offline receipts without an FBR number | Queue + reprint flow; confirm the acceptable practice with the client's tax consultant |
| Printer model not chosen yet | USB RAW printing via the Windows spooler is driver-agnostic; 58/80mm configurable; test-print screen |
| Low-end shop PC | Flutter release build is light; test at 1366×768 with 4GB RAM |

---

## 11. Decisions log

| # | Decision | Date |
|---|---|---|
| 1 | Café = **Essence**; invoices go to the owner's company **Mix & Match Collection** | 2026-10-16 |
| 2 | Location Islamabad/Rawalpindi → **FBR**. Separate Cash and Card/Online rates | 2026-10-16 |
| 3 | Printer: **USB** (model decided later) | 2026-10-16 |
| 4 | All order types (dine-in + tables, takeaway, delivery), service charge, inclusive/exclusive pricing, all configurable in Settings | 2026-10-16 |
| 5 | GST is fixed with an **Enable GST** toggle; extra **Other taxes** can be added; rates are custom values only (no presets), default **Cash 15% / Card-Online 5%**. Inclusive pricing shows the included tax at the paid method's % on the bill | 2026-10-16 |

### Still open (not blocking)

- Printer model and cash drawer (needed by Phase 3)
- Number of terminals at launch
- Demo date
