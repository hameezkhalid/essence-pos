import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../models/order_models.dart';
import '../models/settings_models.dart';
import '../tax/tax_engine.dart';
import '../sync/sync_engine.dart';

class FiscalResult {
  const FiscalResult.reported(this.invoiceNo) : error = null;
  const FiscalResult.failed(this.error) : invoiceNo = null;
  final String? invoiceNo;
  final String? error;
  bool get ok => invoiceNo != null;
}

/// Reports a sale to the tax authority and returns its fiscal invoice number.
/// The receipt prints that number and a QR code of it.
abstract class FiscalAdapter {
  Future<FiscalResult> submit(Order order, FbrSettings settings, StoreSettings store);
}

/// FBR POS integration (IMS) — posts each sale and returns FBR's invoice number.
class FbrImsAdapter implements FiscalAdapter {
  FbrImsAdapter({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const sandboxUrl = 'https://esp.fbr.gov.pk:8244/FBR/v1/api/Live/PostData';
  static const liveUrl = 'https://gw.fbr.gov.pk/imsp/v1/api/Live/PostData';

  @override
  Future<FiscalResult> submit(Order order, FbrSettings settings, StoreSettings store) async {
    if (!settings.hasCredentials) return const FiscalResult.failed('Add the FBR POS ID and token in Settings › FBR');
    final body = fbrInvoicePayload(order, settings);
    final http.Response r;
    try {
      r = await _client
          .post(
            Uri.parse(settings.mode == FbrMode.live ? liveUrl : sandboxUrl),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${settings.token.trim()}'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      return FiscalResult.failed('FBR not reachable: $e');
    }
    Map<String, dynamic> data = const {};
    try {
      data = Map<String, dynamic>.from(jsonDecode(r.body) as Map);
    } catch (_) {}
    final invoiceNo = (data['InvoiceNumber'] as String?)?.trim() ?? '';
    final code = '${data['Code'] ?? ''}';
    if (r.statusCode == 200 && invoiceNo.isNotEmpty && (code.isEmpty || code == '100')) {
      return FiscalResult.reported(invoiceNo);
    }
    final msg = [data['Response'], data['Errors']].where((e) => e != null && '$e'.isNotEmpty).join(' · ');
    return FiscalResult.failed('FBR ${r.statusCode}${code.isEmpty ? '' : ' / $code'}: ${msg.isEmpty ? r.body : msg}');
  }
}

double _rs(int paisa) => paisa / 100;

/// FBR IMS invoice JSON for a paid order. Tax and discount are shared across lines in
/// proportion to each line's value so the item totals add up to the invoice totals.
Map<String, dynamic> fbrInvoicePayload(Order o, FbrSettings s) {
  final lines = o.lines;
  final tax = _split(o.taxTotal, [for (final l in lines) l.net]);
  final pays = o.payments;
  final paymentMode = pays.length > 1
      ? 5 // mixed
      : (pays.isEmpty || pays.first.group == RateGroup.cash ? 1 : 2); // cash : card / online
  final rateBp = o.taxLines.isEmpty ? 0 : o.taxLines.where((t) => t.group == (pays.firstOrNull?.group ?? RateGroup.cash)).fold<int>(0, (a, t) => a + t.rateBp);
  final saleValue = o.total - o.taxTotal - o.fbrFee - o.rounding;
  return {
    'InvoiceNumber': '',
    'POSID': int.tryParse(s.posId.trim()) ?? s.posId.trim(),
    'USIN': o.number ?? o.id,
    'DateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(o.paidAt ?? o.createdAt)),
    'BuyerNTN': '',
    'BuyerCNIC': '',
    'BuyerName': o.customerName ?? '',
    'BuyerPhoneNumber': o.customerPhone ?? '',
    'TotalBillAmount': _rs(saleValue + o.taxTotal),
    'TotalQuantity': lines.fold<int>(0, (a, l) => a + l.qty),
    'TotalSaleValue': _rs(saleValue),
    'TotalTaxCharged': _rs(o.taxTotal),
    'Discount': _rs(o.discountTotal),
    'FurtherTax': 0,
    'PaymentMode': paymentMode,
    'RefUSIN': null,
    'InvoiceType': 1,
    'Items': [
      for (var i = 0; i < lines.length; i++)
        () {
          final l = lines[i];
          final lineSale = o.pricesIncludeTax ? l.net - tax[i] : l.net;
          return {
            'ItemCode': l.productId,
            'ItemName': l.title,
            'Quantity': l.qty,
            'PCTCode': s.pctCode.trim().isEmpty ? '00000000' : s.pctCode.trim(),
            'TaxRate': rateBp / 100,
            'SaleValue': _rs(lineSale),
            'TotalAmount': _rs(lineSale + tax[i]),
            'TaxCharged': _rs(tax[i]),
            'Discount': _rs(l.gross - l.net < 0 ? 0 : l.gross - l.net),
            'FurtherTax': 0,
            'InvoiceType': 1,
            'RefUSIN': null,
          };
        }(),
    ],
  };
}

List<int> _split(int amount, List<int> weights) {
  final total = weights.fold<int>(0, (a, b) => a + b);
  if (total <= 0) return List.filled(weights.length, 0);
  final out = [for (final w in weights) amount * w ~/ total];
  var left = amount - out.fold<int>(0, (a, b) => a + b);
  for (var i = 0; left > 0 && i < out.length; i++, left--) {
    out[i]++;
  }
  return out;
}

/// Watches orders waiting for a fiscal number and reports them whenever the device is online.
class FiscalQueue {
  FiscalQueue(this.db, this.sync, this.settings, {Map<FbrMode, FiscalAdapter>? adapters})
      : adapters = adapters ?? {FbrMode.sandbox: FbrImsAdapter(), FbrMode.live: FbrImsAdapter()};

  final AppDatabase db;
  final SyncEngine sync;
  final AppSettings Function() settings;
  final Map<FbrMode, FiscalAdapter> adapters;

  StreamSubscription<dynamic>? _ordersSub;
  StreamSubscription<dynamic>? _statusSub;
  Timer? _timer;
  bool _running = false;
  String _deviceId = '';

  void start(String deviceId) {
    _deviceId = deviceId;
    // Only this terminal reports its own invoices (avoids double reporting across terminals).
    final q = db.select(db.orders)
      ..where((o) => o.fiscalStatus.equals('pending') & o.deviceId.equals(deviceId) & o.deleted.equals(false));
    _ordersSub = q.watch().listen((_) => run());
    _statusSub = sync.statusStream.listen((s) {
      if (s.online) run();
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => run());
  }

  Future<void> run() async {
    if (_running || !sync.status.online) return;
    _running = true;
    try {
      final s = settings();
      // FBR invoices switched off: nothing is reported (sales made while off are never queued).
      if (!s.fbr.enabled) return;
      final pending = await (db.select(db.orders)
            ..where((o) => o.fiscalStatus.equals('pending') & o.deviceId.equals(_deviceId) & o.deleted.equals(false))
            ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
            ..limit(50))
          .get();
      for (final o in pending) {
        if (!sync.status.online) break;
        final adapter = adapters[s.fbr.mode]!;
        FiscalResult r;
        try {
          r = await adapter.submit(o, s.fbr, s.store).timeout(const Duration(seconds: 20));
        } catch (e) {
          r = FiscalResult.failed('$e');
        }
        final fresh = await (db.select(db.orders)..where((x) => x.id.equals(o.id))).getSingle();
        await db.saveSynced(
          db.orders,
          fresh.copyWith(
            fiscalStatus: r.ok ? 'reported' : 'pending',
            fiscalInvoiceNo: Value(r.invoiceNo ?? fresh.fiscalInvoiceNo),
            fiscalError: Value(r.error),
            fiscalAt: Value(r.ok ? nowMs() : fresh.fiscalAt),
            updatedAt: nowMs(),
          ),
        );
        if (!r.ok) break;
      }
    } finally {
      _running = false;
    }
  }

  void stop() {
    _ordersSub?.cancel();
    _statusSub?.cancel();
    _timer?.cancel();
  }
}
