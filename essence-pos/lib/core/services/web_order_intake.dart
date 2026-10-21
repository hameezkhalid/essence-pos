import 'dart:async';

import 'package:flutter/foundation.dart';

import '../db/database.dart';
import '../models/cart.dart';
import '../models/menu_models.dart';
import '../models/order_models.dart';
import '../models/settings_models.dart';
import '../money.dart';
import '../sync/web_order_inbox.dart';
import 'pos_context.dart';
import 'pos_service.dart';

/// Who "took" a website order. Never saved, so it doesn't appear on the lock screen; the cashier
/// who takes payment replaces it at checkout.
const kWebStaff = StaffMember(
  id: 'web',
  updatedAt: 0,
  deleted: false,
  name: 'Website',
  role: 'cashier',
  pinHash: '',
  pinSalt: '',
  active: true,
  color: 0xFF4E5726,
);

/// Device-local switch: does this till receive website orders? (on unless turned off)
const kReceiveOnlineMeta = 'online.receive';

class WebOrderArrived {
  const WebOrderArrived(this.code, this.order);
  final String code;
  final Order order;
}

/// Lines rebuilt from the POS menu, plus anything the cashier should know about.
class WebCart {
  const WebCart(this.lines, this.issues);
  final List<OrderLine> lines;
  final List<String> issues;
}

/// Turns website lines into order lines priced from this till's menu (website prices are never trusted).
WebCart mapWebLines(String code, List<WebOrderLine> input, Map<String, Product> products, Map<String, ModifierGroup> groups) {
  final lines = <OrderLine>[];
  final issues = <String>[];
  for (final w in input.take(30)) {
    final p = products[w.productId];
    if (p == null || p.deleted || !p.active) {
      issues.add('An item is no longer on the menu (${w.productId})');
      continue;
    }
    if (!p.available) issues.add('${p.name} is marked sold out');
    final sizes = p.sizes;
    ProductSize? size;
    if (sizes.isNotEmpty) {
      final fallback = sizes.firstWhere((s) => s.delta == 0, orElse: () => sizes.first);
      size = sizes.where((s) => s.code == w.sizeCode).firstOrNull ?? fallback;
      if (w.sizeCode != null && size.code != w.sizeCode) issues.add('${p.name}: size changed to ${size.label}');
    }
    final modifiers = <SelectedModifier>[
      for (final gid in p.modifierGroupIds)
        if (groups[gid] case final g? when !g.deleted)
          ...g.options
              .where((o) => w.optionIds.contains(o.id))
              .take(g.maxSelect > 0 ? g.maxSelect : 99)
              .map((o) => SelectedModifier(groupId: g.id, groupName: g.name, option: o)),
    ];
    final line = OrderLine(
      key: 'web-$code-${lines.length}',
      productId: p.id,
      categoryId: p.categoryId,
      name: p.name,
      basePrice: p.price,
      size: size,
      modifiers: modifiers,
      qty: w.qty.clamp(1, 20),
      taxExempt: p.taxExempt,
    );
    final i = lines.indexWhere((l) => l.signature == line.signature);
    if (i >= 0) {
      lines[i] = lines[i].copyWith(qty: (lines[i].qty + line.qty).clamp(1, 20));
    } else {
      lines.add(line);
    }
  }
  return WebCart(lines, issues);
}

/// Public store info the website shows (stores/{store}/public/site).
Map<String, dynamic> publicSiteInfo(StoreSettings store, OnlineOrderSettings online) => {
      'accepting': online.accepting,
      'whatsapp': online.whatsapp.trim(),
      'hours': online.hours.trim(),
      'address': store.address.trim(),
      'phone': store.phone.trim(),
      'storeName': store.name,
    };

/// Listens for website orders and turns each into a held order on this till.
class WebOrderIntake {
  WebOrderIntake(this.db, this.pos, this.inbox, this.device);

  final AppDatabase db;
  final PosService pos;
  final WebOrderInbox inbox;
  final DeviceInfo device;

  final _events = StreamController<WebOrderArrived>.broadcast();
  StreamSubscription<String?>? _switch;
  StreamSubscription<List<WebOrderDoc>>? _sub;
  Timer? _retry;
  final _done = <String>{};
  final _busy = <String>{};
  List<WebOrderDoc> _latest = const [];
  Future<void> _queue = Future.value();

  /// New online orders, for the chime and toast.
  Stream<WebOrderArrived> get events => _events.stream;

  bool get receiving => _sub != null;

  void start() {
    _switch ??= db.watchMeta(kReceiveOnlineMeta).listen((v) => v == 'false' ? _stopListening() : _startListening());
  }

  void _startListening() {
    if (_sub != null) return;
    _sub = inbox.watchPending(device.id).listen(_onPending, onError: (Object e) => debugPrint('web orders: $e'));
    // Retry anything that failed (e.g. a dropped connection mid-claim).
    _retry = Timer.periodic(const Duration(seconds: 45), (_) => _onPending(_latest));
    unawaited(publishSite());
  }

  void _stopListening() {
    _sub?.cancel();
    _sub = null;
    _retry?.cancel();
    _retry = null;
  }

  Future<void> publishSite() async {
    try {
      await inbox.publishSite(publicSiteInfo(pos.settings.store, pos.settings.online));
      await inbox.heartbeat(device.code);
    } catch (e) {
      debugPrint('web orders: publish failed: $e');
    }
  }

  Future<void> heartbeat() async {
    if (!receiving) return;
    try {
      await inbox.heartbeat(device.code);
    } catch (_) {}
  }

  void _onPending(List<WebOrderDoc> docs) {
    _latest = docs;
    for (final d in docs) {
      if (_done.contains(d.code) || _busy.contains(d.code)) continue;
      _busy.add(d.code);
      _queue = _queue.then((_) => _process(d)).whenComplete(() => _busy.remove(d.code));
    }
  }

  Future<void> _process(WebOrderDoc doc) async {
    try {
      final order = await receive(doc);
      _done.add(doc.code);
      if (order != null) _events.add(WebOrderArrived(doc.code, order));
    } catch (e) {
      debugPrint('web orders: #${doc.code} failed: $e');
    }
  }

  /// Claims [doc] and creates its held order. Returns null when another till has it or it already exists.
  @visibleForTesting
  Future<Order?> receive(WebOrderDoc doc) async {
    if (!await inbox.claim(doc.code, device.id)) return null;
    final id = 'web-${doc.code}';
    final existing = await (db.select(db.orders)..where((o) => o.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      await inbox.markInPos(doc.code, orderId: id, subtotal: existing.itemsGross);
      return null;
    }
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final groups = {for (final g in await db.select(db.modifierGroups).get()) g.id: g};
    final mapped = mapWebLines(doc.code, doc.lines, products, groups);
    final note = [
      'Website pickup #${doc.code}',
      if (doc.note.isNotEmpty) 'Customer: ${doc.note}',
      ...mapped.issues,
    ].join(' · ');
    final cart = CartState(
      lines: mapped.lines,
      type: OrderType.takeaway,
      customerName: doc.name.isEmpty ? 'Web #${doc.code}' : doc.name,
      customerPhone: doc.phone,
      note: note,
      heldOrderId: id,
    );
    final order = await pos.hold(cart, staff: kWebStaff, sendToBar: pos.settings.online.sendToBar && mapped.lines.isNotEmpty);
    await inbox.markInPos(doc.code, orderId: order.id, subtotal: order.itemsGross);
    return order;
  }

  Future<void> cancel(Order o) async {
    final code = o.webCode;
    if (code == null) return;
    try {
      await inbox.markCancelled(code);
    } catch (e) {
      debugPrint('web orders: cancel #$code failed: $e');
    }
  }

  void dispose() {
    _stopListening();
    _switch?.cancel();
    _events.close();
  }
}

// ───────────── WhatsApp ─────────────

/// 0300-1234567 / +92 300 1234567 → 923001234567 (wa.me format). Empty when it isn't a number.
String waNumber(String phone) {
  final d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('92')) return d;
  if (d.startsWith('0')) return '92${d.substring(1)}';
  if (d.length == 10 && d.startsWith('3')) return '92$d';
  return d;
}

/// Fills a message template for [o].
String fillTemplate(String template, Order o, AppSettings s) {
  final name = (o.customerName ?? '').startsWith('Web #') ? '' : (o.customerName ?? '').trim();
  return template
      .replaceAll('{name}', name.isEmpty ? 'there' : name.split(' ').first)
      .replaceAll('{code}', o.webCode ?? o.tokenLabel.replaceAll('#', ''))
      .replaceAll('{items}', o.lines.map((l) => '${l.qty}× ${l.title}').join('\n'))
      .replaceAll('{subtotal}', rs(o.itemsGross))
      .replaceAll('{store}', s.store.name);
}

Uri whatsAppUri(String phone, String text) => Uri.parse('https://wa.me/${waNumber(phone)}?text=${Uri.encodeComponent(text)}');
