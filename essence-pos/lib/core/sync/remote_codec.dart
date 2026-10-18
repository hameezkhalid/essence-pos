import 'dart:convert';

import '../db/database.dart';

/// Converts Firestore documents back into the app's row types without a local database
/// (used by the web dashboard). Mirrors [SyncSpec.fromRemote].
Map<String, dynamic> remoteToLocal(String id, Map<String, dynamic> data, {Set<String> jsonFields = const {}, Set<String> realFields = const {}}) {
  final out = <String, dynamic>{};
  data.forEach((k, v) {
    if (k == 'syncedAt') return;
    final jk = '${k}Json';
    if (jsonFields.contains(jk)) {
      out[jk] = v is String ? v : jsonEncode(v);
    } else if (realFields.contains(k) && v is num) {
      out[k] = v.toDouble();
    } else {
      out[k] = v;
    }
  });
  out['id'] = id;
  out['updatedAt'] = (out['updatedAt'] as num?)?.toInt() ?? 0;
  out['deleted'] ??= false;
  return out;
}

const _orderJson = {'linesJson', 'orderDiscountJson', 'chargesJson', 'taxLinesJson', 'paymentsJson'};

Order orderFromRemote(String id, Map<String, dynamic> data) => Order.fromJson(remoteToLocal(id, data, jsonFields: _orderJson));

Refund refundFromRemote(String id, Map<String, dynamic> data) => Refund.fromJson(remoteToLocal(id, data, jsonFields: const {'linesJson'}));

Terminal terminalFromRemote(String id, Map<String, dynamic> data) => Terminal.fromJson(remoteToLocal(id, data));

MenuCategory categoryFromRemote(String id, Map<String, dynamic> data) => MenuCategory.fromJson(remoteToLocal(id, data));

/// Settings documents keep their section map under `value`.
Map<String, dynamic> settingValueFromRemote(Map<String, dynamic> data) {
  final v = data['value'];
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is String) {
    try {
      return Map<String, dynamic>.from(jsonDecode(v) as Map);
    } catch (_) {}
  }
  return {};
}
