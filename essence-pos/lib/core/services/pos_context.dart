import 'dart:async';

import 'package:intl/intl.dart';

import '../db/database.dart';
import '../models/settings_models.dart';
import '../tax/tax_engine.dart';
import 'repos.dart';

class DeviceInfo {
  const DeviceInfo({required this.id, required this.code, required this.name});
  final String id;

  /// Short terminal code printed on invoices, e.g. T1.
  final String code;
  final String name;
}

final _dateKey = DateFormat('yyyy-MM-dd');

/// Business day for a timestamp: sales before [dayStartHour] belong to the previous day.
String businessDateFor(DateTime t, int dayStartHour) => _dateKey.format(t.subtract(Duration(hours: dayStartHour)));

DateTime parseBusinessDate(String d) => DateTime.parse(d);

/// Latest store settings, taxes and payment methods, kept in memory for synchronous use.
class PosContext {
  PosContext(this.db, this.device) : _settingsRepo = SettingsRepo(db);

  final AppDatabase db;
  DeviceInfo device;
  final SettingsRepo _settingsRepo;

  AppSettings settings = const AppSettings();
  List<TaxRow> taxes = const [];
  List<PaymentMethod> methods = const [];
  final _subs = <StreamSubscription<dynamic>>[];
  final _ready = Completer<void>();

  Future<void> start() async {
    var pending = 3;
    void ready() {
      if (--pending == 0 && !_ready.isCompleted) _ready.complete();
    }

    var a = false, b = false, c = false;
    _subs.add(_settingsRepo.watch().listen((s) {
      settings = s;
      if (!a) {
        a = true;
        ready();
      }
    }));
    _subs.add(_settingsRepo.watchTaxes().listen((t) {
      taxes = t;
      if (!b) {
        b = true;
        ready();
      }
    }));
    _subs.add(_settingsRepo.watchPaymentMethods().listen((m) {
      methods = m;
      if (!c) {
        c = true;
        ready();
      }
    }));
    await _ready.future;
  }

  BillConfig get billConfig => billConfigFrom(settings, taxes);

  String businessDate([DateTime? t]) => businessDateFor(t ?? DateTime.now(), settings.store.dayStartHour);

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
  }
}
