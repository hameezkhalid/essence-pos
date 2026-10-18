import 'dart:convert';

enum PrinterKind {
  /// USB/installed printer on Windows, sent RAW through the print spooler.
  windows('Windows printer (USB)'),

  /// Installed printer on macOS/Linux, sent RAW through CUPS (`lp -o raw`).
  cups('System printer (USB)'),

  /// Network printer on raw TCP port 9100.
  network('Network (LAN / Wi-Fi)');

  const PrinterKind(this.label);
  final String label;
  static PrinterKind parse(String? v) => PrinterKind.values.firstWhere((k) => k.name == v, orElse: () => PrinterKind.windows);
}

enum PrintRole {
  receipt('Customer receipts'),
  kot('Bar / kitchen tickets (KOT)'),
  report('Shift & sales reports');

  const PrintRole(this.label);
  final String label;
}

class PrinterConfig {
  const PrinterConfig({
    required this.id,
    required this.name,
    required this.kind,
    required this.target,
    this.paperMm = 80,
    this.roles = const {PrintRole.receipt, PrintRole.kot, PrintRole.report},
    this.cashDrawer = true,
    this.nativeQr = true,
    this.enabled = true,
  });

  final String id;
  final String name;
  final PrinterKind kind;

  /// Printer name for windows/cups, or host[:port] for network.
  final String target;
  final int paperMm;
  final Set<PrintRole> roles;

  /// A cash drawer is connected to this printer's drawer port.
  final bool cashDrawer;
  final bool nativeQr;
  final bool enabled;

  int get columns => paperMm >= 80 ? 48 : 32;
  int get dots => paperMm >= 80 ? 576 : 384;

  PrinterConfig copyWith({
    String? name,
    PrinterKind? kind,
    String? target,
    int? paperMm,
    Set<PrintRole>? roles,
    bool? cashDrawer,
    bool? nativeQr,
    bool? enabled,
  }) =>
      PrinterConfig(
        id: id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        target: target ?? this.target,
        paperMm: paperMm ?? this.paperMm,
        roles: roles ?? this.roles,
        cashDrawer: cashDrawer ?? this.cashDrawer,
        nativeQr: nativeQr ?? this.nativeQr,
        enabled: enabled ?? this.enabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'target': target,
        'paperMm': paperMm,
        'roles': roles.map((r) => r.name).toList(),
        'cashDrawer': cashDrawer,
        'nativeQr': nativeQr,
        'enabled': enabled,
      };

  static PrinterConfig fromJson(Map j) => PrinterConfig(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'Printer',
        kind: PrinterKind.parse(j['kind'] as String?),
        target: j['target'] as String? ?? '',
        paperMm: (j['paperMm'] as num?)?.toInt() ?? 80,
        roles: {
          for (final r in (j['roles'] as List? ?? const []))
            ...PrintRole.values.where((x) => x.name == r),
        },
        cashDrawer: j['cashDrawer'] as bool? ?? true,
        nativeQr: j['nativeQr'] as bool? ?? true,
        enabled: j['enabled'] as bool? ?? true,
      );

  static List<PrinterConfig> listFromJson(String? s) {
    if (s == null || s.isEmpty) return const [];
    return (jsonDecode(s) as List).whereType<Map>().map(PrinterConfig.fromJson).toList();
  }

  static String listToJson(List<PrinterConfig> l) => jsonEncode(l.map((p) => p.toJson()).toList());
}
