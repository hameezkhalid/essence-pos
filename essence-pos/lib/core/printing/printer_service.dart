import 'dart:async';

import 'package:flutter/services.dart';

import '../db/database.dart';
import 'escpos.dart';
import 'printer_config.dart';
import 'receipt_doc.dart';
import 'transport.dart';

class PrintResult {
  const PrintResult(this.printed, this.errors);
  final int printed;
  final List<String> errors;
  bool get ok => errors.isEmpty;
  bool get nothingConfigured => printed == 0 && errors.isEmpty;
}

/// Device-local printer setup and printing. Printer configs live in local meta because
/// USB printer names differ per computer.
class PrinterService {
  PrinterService(this.db);
  final AppDatabase db;

  static const _key = 'printers';
  Uint8List? _logo;

  Stream<List<PrinterConfig>> watchPrinters() => db.watchMeta(_key).map(PrinterConfig.listFromJson);
  Future<List<PrinterConfig>> printers() async => PrinterConfig.listFromJson(await db.getMeta(_key));

  Future<void> savePrinters(List<PrinterConfig> list) => db.setMeta(_key, PrinterConfig.listToJson(list));

  Future<Uint8List?> _logoBytes() async {
    if (_logo != null) return _logo;
    try {
      _logo = (await rootBundle.load('assets/images/receipt_logo.png')).buffer.asUint8List();
    } catch (_) {}
    return _logo;
  }

  Future<Uint8List> render(ReceiptDoc doc, PrinterConfig p) async =>
      EscPosRenderer(columns: p.columns, dotsWidth: p.dots, logoPng: await _logoBytes(), nativeQr: p.nativeQr).render(doc);

  /// Prints [doc] on every enabled printer that has [role]. Opens the drawer on the first
  /// receipt printer with a drawer when [doc.openDrawer] is set.
  Future<PrintResult> print(ReceiptDoc doc, PrintRole role, {int copies = 1}) async {
    if (!printingSupported) return const PrintResult(0, []);
    final targets = (await printers()).where((p) => p.enabled && p.roles.contains(role)).toList();
    var printed = 0;
    final errors = <String>[];
    var drawerDone = false;
    for (final p in targets) {
      try {
        for (var c = 0; c < copies.clamp(1, 5); c++) {
          final kick = doc.openDrawer && !drawerDone && p.cashDrawer && c == 0;
          await sendToPrinter(p, await render(doc.withDrawer(kick), p)).timeout(const Duration(seconds: 15));
          if (kick) drawerDone = true;
        }
        printed++;
      } catch (e) {
        errors.add('${p.name}: ${_short(e)}');
      }
    }
    if (doc.openDrawer && !drawerDone) {
      final r = await openDrawer();
      errors.addAll(r.errors);
    }
    return PrintResult(printed, errors);
  }

  Future<PrintResult> openDrawer() async {
    if (!printingSupported) return const PrintResult(0, []);
    final p = (await printers()).where((p) => p.enabled && p.cashDrawer).firstOrNull;
    if (p == null) return const PrintResult(0, []);
    try {
      await sendToPrinter(p, Uint8List.fromList(EscPosRenderer.drawerKick)).timeout(const Duration(seconds: 10));
      return const PrintResult(1, []);
    } catch (e) {
      return PrintResult(0, ['${p.name}: ${_short(e)}']);
    }
  }

  Future<PrintResult> printOn(PrinterConfig p, ReceiptDoc doc) async {
    try {
      await sendToPrinter(p, await render(doc, p)).timeout(const Duration(seconds: 15));
      return const PrintResult(1, []);
    } catch (e) {
      return PrintResult(0, ['${p.name}: ${_short(e)}']);
    }
  }

  static String _short(Object e) {
    final s = e.toString().replaceFirst('Exception: ', '');
    return s.length > 120 ? '${s.substring(0, 120)}…' : s;
  }
}
