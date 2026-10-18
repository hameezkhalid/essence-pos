# Essence POS

Point of sale for **Essence — Patisserie · Coffee · Moments** (Islamabad / Rawalpindi), built by NIBNOX.
Basic variant from the Brew OS proposal: offline-first POS, live sync, basic inventory, receipt printing,
FBR-ready invoicing (simulated in the demo), plus an owner's live dashboard on the web.

- Flutter 3.47 · Dart 3.13 · Riverpod 3 · Drift (SQLite) · Firebase (Auth, Firestore, Hosting)
- Firebase project: `essenceisb` · store id: `essence`
- Architecture & conventions: [ARCHITECTURE.md](ARCHITECTURE.md) · Plan: [../docs/POS-PLAN.md](../docs/POS-PLAN.md)

## Run it

```bash
flutter pub get
flutter run -d macos      # development on a Mac
flutter run -d windows    # on the shop's Windows PC
flutter run -d chrome     # the owner dashboard (web build)
```

### Signing in on a Mac (development)
Firebase Auth on macOS stores the session in the keychain, which needs a signed app. One-time setup:
1. Xcode › Settings › Accounts › **+** › add your Apple ID (a free account is fine).
2. Open `macos/Runner.xcworkspace` › target **Runner** › *Signing & Capabilities* › **Team**: pick your team.
3. Still there: **+ Capability › Keychain Sharing** (Xcode adds the keychain group).

Windows doesn't need this.

### Logins
There is no public sign-up. The store was seeded with one admin login:

| Login | Password | Role |
|---|---|---|
| `admin@essence.com` | *(shared separately)* | Admin (owns the `essence` store) |

Admins add more logins (one per till, the owner's dashboard…) in **Settings › Store logins**, and can
make a login an admin, send a password-reset email, or remove its access. Change the seeded password
before going live (Store logins › Send password reset email).

### First launch of a till
1. **Sign in** with a store login.
2. **Set up this till** — name and code (T1, T2 … the code is printed on invoice numbers, e.g. `ESS-T1-000482`).
   On the very first till, keep **Load demo data** on for the demo: patisserie menu (44 items) with sizes and
   extras, recipes and stock for 27 ingredients, 3 staff, 12 tables, 12 customers and 30 days of sales.
3. Staff sign in with their PIN. Demo PINs: **Owner 1111 · Manager 2222 · Cashier 3333**.

Further tills sign in (with their own login, or the same one) and **join**, which downloads everything.

## Build & install on Windows

On a Windows 10/11 PC with Flutter and Visual Studio (Desktop development with C++):

```bash
flutter build windows --release
dart run msix:create            # → build/windows/x64/runner/Release/essence_pos.msix
```

Install the `.msix` (or copy the `Release` folder). USB receipt printers: install the printer's Windows driver
first, then add it in **Settings › Printers** (kind *Windows printer (USB)*), press **Test print**.

## Owner dashboard (web)

```bash
flutter build web --release
firebase deploy --only hosting   # serves build/web on https://essenceisb.web.app
```

Not deployed yet — run the commands above when you're ready to publish it.

## Tests

```bash
flutter test                                   # tax engine, services, two-terminal sync
flutter test test_screens --update-goldens     # renders every screen to test_screens/out/*.png for review
```

## Demo walkthrough (10 minutes)

1. **Sell** — tap *Cappuccino* (choose Large + Oat milk), two *Butter Croissants*, *Basque Cheesecake*.
   The cart shows the **cash total (GST 15%)** and **card/online total (GST 5%)** side by side.
2. **Charge** → Cash → tap *Rs 3,000* → change is shown → **Sale complete** with the receipt; a moment later
   the receipt fills in the **FBR invoice number and QR code** (simulated).
3. **Offline** — tap the green *Online* pill → *Work offline (demo)*. Ring two sales: receipts say
   "FBR invoice pending", the pill counts changes waiting to upload. Switch back online: they upload in order,
   FBR numbers arrive, nothing is duplicated.
4. **Dine-in** — choose *Dine-in*, pick table 5, add items, **Send to bar & hold** (prints a KOT).
   Recall it from *Held orders* (or tap table 5) and charge with a **split payment** (part cash, rest card —
   each part taxed at its own rate).
5. **Settings › Tax** — switch *Menu prices include tax*: the total equals the menu prices and the receipt
   shows "incl. GST 15%" (cash) or "incl. GST 5%" (card). Add an "Other tax". Change rates — every till updates live.
6. **Inventory** — each sale deducted its recipe (oat milk instead of milk!). Caramel syrup and oat milk are low:
   *Reorder* tab → print the purchase list → *Stock in*.
7. **Orders** — reprint, partial **refund** (manager PIN 2222 when signed in as the cashier), **void**.
8. **Shift** — cash in/out, X-report, **close shift** with the denomination counter → Z-report, over/short.
9. **Reports** — today vs previous period, sales by hour, payment mix, tax by rate (cash vs card), top items, CSV export.
10. **Owner dashboard** (web) — the same sales appear live on the owner's phone.

## After the demo

- Replace demo data with the real menu (Settings › Data › Clear sales history, then edit Menu), or set up a
  fresh store without demo data.
- Real FBR reporting: implement `FbrImsAdapter` in `lib/core/fiscal/fiscal.dart` with the POS ID and token FBR
  issues, then switch **Settings › FBR** from *Demo* to *Sandbox* / *Live*.
