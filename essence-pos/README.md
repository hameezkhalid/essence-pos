# Essence POS

Point of sale for **Essence — Patisserie · Coffee · Moments** (Islamabad / Rawalpindi), built by NIBNOX.

One codebase, two apps:

| Build | What it is | Where |
|---|---|---|
| **Windows** | The till (POS) | `essence_pos.exe` from the GitHub Actions build |
| **Web** | The admin panel: live dashboard, menu, inventory, reports, settings — and the same POS | Firebase Hosting: https://essence-admin.web.app |

- Flutter 3.47 · Dart 3.13 · Riverpod 3 · Drift (SQLite; IndexedDB in the browser) · Firebase (Auth, Firestore, Hosting)
- Firebase project `essenceisb` · store id `essence`
- Architecture & conventions: [ARCHITECTURE.md](ARCHITECTURE.md) · Plan: [../docs/POS-PLAN.md](../docs/POS-PLAN.md)

## Logins

There is no public sign-up. The store has one seeded admin login, `admin@essence.com` (password shared
separately — change it before go-live). Admins add more logins (one per till, the owner's phone…) in
**Settings › Store logins**, make a login an admin, send password-reset emails or remove access.

After the store login, staff unlock the app with their 4-digit PIN (**Settings › Staff & roles**). The store
still has the three staff created for the demo — rename them and change their PINs.

## Menu

The Essence dessert menu is loaded: Chocolate Favourites (Chocolate Fudge Brownie, Chocolate Cake, OG Cookies),
Fresh & Fruity (Lemon Tart, Lemon Cake, Blueberry Cheesecake, Banana Bread) and Signature Desserts (Tres Leches
Cake, Tiramisu, Salted Caramel Cheesecake, Marble Cake), with photos from the printed menu.

**Prices are starting values — set the real prices in Admin panel › Menu.** Add, edit, hide (sold out / inactive)
or delete products there; every till updates live. The demo menu from earlier testing is hidden (kept in the
database, not shown anywhere).

## Inventory

Each dessert has a stock item counted in pieces; every sale deducts one. Record the day's bake each morning with
**Inventory › Stock in** (or set exact counts with **Count**). Items show Low / Out when they run down.

## FBR invoices

**Settings › FBR invoices** has an on/off switch (off by default):

- **Off** — FBR is bypassed: plain sales receipts, no FBR POS fee, nothing reported. Use this until the
  credentials arrive. Sales made while off are never sent to FBR.
- **On** — every sale is reported to FBR (IMS API) from the till that made it. Receipts become sales tax
  invoices with the FBR invoice number, QR code and the Rs 1 FBR POS fee. If a till is offline, invoices queue
  and are reported automatically when it reconnects.

To go live: enter the **POS ID**, **token** and **PCT code** from FBR, choose **Live** (or Sandbox to test),
switch FBR invoices on and save. Report FBR sales from the Windows tills (browsers can't call FBR's API).

## Build the Windows app

Push to `main` (or run the workflow from the Actions tab) — GitHub Actions builds it on Windows:
**Actions › Build Windows app › latest run › Artifacts › essence-pos-windows**. Unzip on the PC and run
`essence_pos.exe` (keep the `data` folder and DLLs next to it). Windows may warn that the app is unsigned:
*More info › Run anyway*.

Local build on a Windows PC: `powershell -ExecutionPolicy Bypass -File tool\build_windows.ps1`.

USB receipt printers: install the printer's Windows driver, then **Settings › Printers › Add** and **Test print**.

## Deploy the admin panel (web)

```bash
flutter build web --release
firebase deploy --only hosting
```

The browser database needs `web/sqlite3.wasm` (from the sqlite3 3.5.2 release) and `web/drift_worker.js`
(compiled with `dart compile js -O4 -o web/drift_worker.js tool/web/drift_worker.dart`). Rebuild both when
upgrading `sqlite3`/`drift`.

## Develop

```bash
flutter pub get
flutter run -d chrome     # admin panel
flutter run -d macos      # till (needs a signing team for Firebase Auth; see below)
flutter test              # tax engine, services, FBR payload, two-terminal sync
flutter test test_screens --update-goldens   # renders screens to test_screens/out/*.png
```

macOS sign-in needs Keychain Sharing: in Xcode open `macos/Runner.xcworkspace` › Runner › Signing &
Capabilities › pick your Team (with a development certificate) › + Capability › Keychain Sharing.

`tool/golive/` holds the one-time go-live update that hid the demo menu and loaded the dessert menu
(`flutter test tool/golive` generates `build/golive.json`; `tool/golive/apply.sh` applies it).

## Day-one checklist

1. Admin panel › **Menu**: set real prices; hide anything not on sale today.
2. **Settings › Store profile**: address, phone, NTN, STRN (printed on receipts).
3. **Settings › Staff & roles**: real staff names and new PINs.
4. **Settings › Store logins**: a login per till; change the admin password.
5. Windows till: **Settings › Printers** (USB printer + cash drawer), then a test print.
6. Each morning: **Inventory › Stock in** the day's desserts; open the shift with the cash float.
7. When FBR sends the credentials: **Settings › FBR invoices** → POS ID, token, PCT code → Live → On.
