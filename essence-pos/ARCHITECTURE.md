# Essence POS — Architecture & conventions

Flutter app (Windows desktop first, also macOS for development, Android tablets, and a web build that is the owner's live dashboard). Firebase project `essenceisb`, store id `essence`.

## Layers

```
lib/
  main.dart                 web → DashboardApp, everything else → BootApp
  app/
    boot.dart               Firebase + SQLite start-up, sign-in, terminal setup, BootActions (sign out, reset demo, clear sales)
    services.dart           AppServices: one object holding every service for a running terminal
    providers.dart          Riverpod providers (read these from widgets)
    router.dart, pos_app.dart, theme/ (tokens.dart, theme.dart, icons.dart)
  core/                     no Flutter widgets here
    db/                     Drift (SQLite) schema + AppDatabase (+ generated database.g.dart)
    sync/                   SyncEngine (outbox push + live pull), RemoteStore, FirestoreRemote
    tax/tax_engine.dart     pure bill maths (GST cash vs card/online, other taxes, inclusive/exclusive, split)
    models/                 JSON-column models (OrderLine, PaymentRecord…), CartState, settings models
    services/               PosService, ShiftService, InventoryService, repos, reports (SalesReport), demo data
    printing/               ReceiptDoc → ESC/POS bytes, templates (receipt, KOT, X/Z), transports (Windows spooler, CUPS, LAN)
    fiscal/                 FiscalAdapter (MockFbrAdapter now, FbrImsAdapter later) + FiscalQueue
  shared/                   reusable widgets: common.dart, keypads.dart, receipt_preview.dart, approval.dart
  features/<feature>/       screens
  dashboard/                web owner dashboard (reads Firestore directly)
```

## Rules

* **UI reads SQLite only** (through providers/streams), so it is instant and works offline.
  Cross-device updates arrive through the SyncEngine and show up automatically.
* **Every write goes through `db.saveSynced(table, row)`** (or a service that does) — it writes the
  row and queues it for Firestore in one transaction. Never write Firestore directly from the POS.
* Rows are never hard-deleted: `copyWith(deleted: true, updatedAt: nowMs())` then `saveSynced`.
  Repos already do this (`deleteX` methods). Always filter `deleted == false`.
* Money is **integer paisa** (`int`), formatted with `rs()` / `num0()` from `core/money.dart`.
  Parse user input with `parseRupees()`. Percentages are **basis points** (1500 = 15%), shown with `pct()`.
* Stock quantities are doubles in base units (`g`, `ml`, `pcs`); format with `StockItem.fmt(q)` / `formatQty`.
* Business dates are `yyyy-MM-dd` strings from `ctx.businessDate()` (day starts at `store.dayStartHour`).

## UI conventions

* Colours only from `context.ec` (EssenceColors: primary olive, beige, accent brown, success/warning/danger…).
  Text styles from `context.tt`. Spacing `Sp.*`, radii `Rad.*`. Never hard-code colours.
* Both light and dark themes must look right. Use `IconBadge`, `Pill(tone: Tone.x)`, `AppCard`, `KpiTile`,
  `EmptyState`, `SectionHeader`, `PageTitle`, `LabeledSwitch`, `QtyStepper`, `ResponsiveGrid`.
* Dialogs: `showAdaptive(context, builder: (_) => DialogFrame(title:…, actions:[…], child:…))` — a dialog on
  desktop/tablet, a bottom sheet on phones. Confirmations: `confirm(context, …)`. Feedback: `toast(context, …)`.
* Responsive: `context.isPhone` (<700), `context.isDesktop` (≥1100). Layouts must work from 360 px wide
  phones up to 1920 px desktops, with no horizontal page scroll. Touch targets ≥ 44 px.
* Permissions: `ref.watch(canProvider(Perm.x))` to show/enable; `await requirePermission(context, ref, Perm.x)`
  before a protected action (returns the approving staff member or null).
* Current staff: `ref.watch(sessionProvider)`. Services: `ref.read(servicesProvider)` (`.pos`, `.shifts`,
  `.inventory`, `.menu`, `.staff`, `.settingsRepo`, `.printer`, `.customers`, `.audit`, `.db`, `.ctx`, `.sync`).
* Icons for stored icon keys: `iconFor(key)` from `app/theme/icons.dart`.
* Screens are `ConsumerWidget`/`ConsumerStatefulWidget`, padded `EdgeInsets.all(Sp.xl)` on desktop and
  `Sp.lg` on phones, and use `PageTitle` at the top.

## Sync

* Firestore: `/stores/essence/{collection}/{id}`; JSON text columns (`linesJson`) are stored as real
  maps/lists without the `Json` suffix (`lines`). Every write gets a server `syncedAt`.
* Pull uses `syncedAt >= cursor` listeners per collection; last-write-wins by `updatedAt`.
* Sales, refunds, stock movements, cash movements, audit logs are append-only (no conflicts).
  Stock level = sum of movements.
* `firestore.rules`: `/stores/essence` lists `memberUids` and `adminUids`. Only members read/write store data; only admins add/remove logins (Settings › Store logins, via `AccountAdmin` + `FirestoreRemote.addAccount`). No public sign-up in the app.

## Tests

`flutter test` — tax engine, services (checkout, stock deduction with modifiers, refunds, voids, shifts,
reports) and two-terminal sync through an in-memory fake cloud.
