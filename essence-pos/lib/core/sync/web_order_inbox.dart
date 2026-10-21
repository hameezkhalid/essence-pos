import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_remote.dart';

/// One line as the website sends it: what was picked, never a price (the POS prices it).
class WebOrderLine {
  const WebOrderLine({required this.productId, required this.qty, this.sizeCode, this.optionIds = const []});
  final String productId;
  final int qty;
  final String? sizeCode;
  final List<String> optionIds;

  static WebOrderLine? fromJson(Object? j) {
    if (j is! Map || j['productId'] is! String) return null;
    return WebOrderLine(
      productId: j['productId'] as String,
      qty: (j['qty'] as num?)?.toInt() ?? 1,
      sizeCode: j['sizeCode'] as String?,
      optionIds: (j['optionIds'] as List? ?? const []).whereType<String>().toList(),
    );
  }
}

/// A pickup order placed on the website: /stores/{store}/webOrders/{code}.
/// status: new → claimed (by one till) → inPos (a held order exists) → cancelled.
class WebOrderDoc {
  const WebOrderDoc({
    required this.code,
    required this.phone,
    this.name = '',
    this.note = '',
    this.lines = const [],
    this.status = 'new',
    this.claimedBy,
    this.createdAt,
  });
  final String code;
  final String phone;
  final String name;
  final String note;
  final List<WebOrderLine> lines;
  final String status;
  final String? claimedBy;
  final DateTime? createdAt;

  static WebOrderDoc fromJson(String code, Map<String, dynamic> j) {
    final ts = j['createdAt'];
    return WebOrderDoc(
      code: code,
      phone: j['phone'] as String? ?? '',
      name: (j['name'] as String? ?? '').trim(),
      note: (j['note'] as String? ?? '').trim(),
      lines: (j['lines'] as List? ?? const []).map(WebOrderLine.fromJson).whereType<WebOrderLine>().toList(),
      status: j['status'] as String? ?? 'new',
      claimedBy: j['claimedBy'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}

/// Where website orders wait for a till, plus the public info the website reads.
abstract class WebOrderInbox {
  /// Orders that still need a held order on a till: new ones, and ones claimed by [deviceId].
  Stream<List<WebOrderDoc>> watchPending(String deviceId);

  /// Takes the order for this till. False when another till got it first.
  Future<bool> claim(String code, String deviceId);
  Future<void> markInPos(String code, {required String orderId, required int subtotal});
  Future<void> markCancelled(String code);

  /// Tells the website a till is receiving orders right now.
  Future<void> heartbeat(String deviceCode);

  /// Public store info for the website (stores/{store}/public/site), merged.
  Future<void> publishSite(Map<String, dynamic> data);
}

class FirestoreWebOrderInbox implements WebOrderInbox {
  FirestoreWebOrderInbox(this.remote);
  final FirestoreRemote remote;

  CollectionReference<Map<String, dynamic>> get _orders => remote.col('webOrders');
  DocumentReference<Map<String, dynamic>> get _site => remote.col('public').doc('site');

  @override
  Stream<List<WebOrderDoc>> watchPending(String deviceId) => _orders
      .where('status', whereIn: ['new', 'claimed'])
      .snapshots()
      .map((s) => [
            for (final d in s.docs)
              if (d.data()['status'] == 'new' || d.data()['claimedBy'] == deviceId) WebOrderDoc.fromJson(d.id, d.data()),
          ]..sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0))));

  @override
  Future<bool> claim(String code, String deviceId) => remote.db.runTransaction((tx) async {
        final ref = _orders.doc(code);
        final snap = await tx.get(ref);
        final d = snap.data();
        if (d == null) return false;
        if (d['status'] == 'claimed' && d['claimedBy'] == deviceId) return true;
        if (d['status'] != 'new') return false;
        tx.update(ref, {'status': 'claimed', 'claimedBy': deviceId, 'claimedAt': FieldValue.serverTimestamp()});
        return true;
      });

  @override
  Future<void> markInPos(String code, {required String orderId, required int subtotal}) =>
      _orders.doc(code).update({'status': 'inPos', 'posOrderId': orderId, 'posSubtotal': subtotal, 'inPosAt': FieldValue.serverTimestamp()});

  @override
  Future<void> markCancelled(String code) =>
      _orders.doc(code).update({'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp()});

  @override
  Future<void> heartbeat(String deviceCode) =>
      _site.set({'intakeSeenAt': FieldValue.serverTimestamp(), 'intakeDevice': deviceCode}, SetOptions(merge: true));

  @override
  Future<void> publishSite(Map<String, dynamic> data) =>
      _site.set({...data, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
}
