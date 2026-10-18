import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/printing/escpos.dart';
import '../../../core/printing/printer_config.dart';
import '../../../core/printing/templates.dart';
import '../../../core/printing/transport.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

IconData printerKindIcon(PrinterKind k) => switch (k) {
      PrinterKind.windows => Icons.usb_rounded,
      PrinterKind.cups => Icons.usb_rounded,
      PrinterKind.network => Icons.lan_outlined,
    };

class PrintersSection extends ConsumerStatefulWidget {
  const PrintersSection({super.key});
  @override
  ConsumerState<PrintersSection> createState() => _PrintersSectionState();
}

class _PrintersSectionState extends ConsumerState<PrintersSection> {
  final _busy = <String>{};

  List<PrinterConfig> get _list => ref.read(printersProvider).value ?? const [];

  Future<void> _saveList(List<PrinterConfig> l) => ref.read(servicesProvider).printer.savePrinters(l);

  Future<void> _edit(PrinterConfig? p) async {
    final r = await showAdaptive<PrinterConfig>(context, maxWidth: 560, builder: (_) => _PrinterDialog(printer: p, existing: _list));
    if (r == null) return;
    final l = [..._list];
    final i = l.indexWhere((x) => x.id == r.id);
    i >= 0 ? l[i] = r : l.add(r);
    await _saveList(l);
    if (mounted) toast(context, p == null ? '${r.name} added' : '${r.name} saved', icon: Icons.print_outlined);
  }

  Future<void> _remove(PrinterConfig p) async {
    final ok = await confirm(context, title: 'Remove ${p.name}?', message: 'This terminal will stop printing to it.', confirmLabel: 'Remove', destructive: true);
    if (!ok) return;
    await _saveList(_list.where((x) => x.id != p.id).toList());
    if (mounted) toast(context, '${p.name} removed');
  }

  Future<void> _run(PrinterConfig p, String what, Future<(bool, String)> Function() f) async {
    setState(() => _busy.add('${p.id}$what'));
    try {
      final (ok, msg) = await f();
      if (mounted) toast(context, msg, error: !ok, icon: ok ? Icons.print_outlined : Icons.print_disabled_outlined);
    } finally {
      if (mounted) setState(() => _busy.remove('${p.id}$what'));
    }
  }

  Future<void> _test(PrinterConfig p) => _run(p, 'test', () async {
        final r = await ref.read(servicesProvider).printer.printOn(p, buildTestPage(p.name, p.paperMm, ref.read(settingsValueProvider)));
        return (r.ok, r.ok ? 'Test page sent to ${p.name}' : r.errors.first);
      });

  Future<void> _drawer(PrinterConfig p) => _run(p, 'drawer', () async {
        try {
          await sendToPrinter(p, Uint8List.fromList(EscPosRenderer.drawerKick)).timeout(const Duration(seconds: 10));
          return (true, 'Drawer kick sent to ${p.name}');
        } catch (e) {
          final s = e.toString().replaceFirst('Exception: ', '');
          return (false, '${p.name}: ${s.length > 120 ? '${s.substring(0, 120)}…' : s}');
        }
      });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(printersProvider);
    final printers = async.value ?? const <PrinterConfig>[];
    return SettingsScaffold(
      title: 'Printers',
      subtitle: 'Receipt and bar printers connected to this terminal. Saved on this device only.',
      actions: [
        if (printingSupported) FilledButton.icon(onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add printer')),
      ],
      children: [
        if (!printingSupported)
          const InfoBanner(
            'Printing is available in the Windows, macOS and Android apps. This version can’t talk to printers.',
            title: 'Printing isn’t available here',
            tone: Tone.warning,
            icon: Icons.print_disabled_outlined,
          ),
        if (async.isLoading && printers.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(Sp.xl), child: CircularProgressIndicator()))
        else if (printers.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.print_outlined,
              title: 'No printers yet',
              message: 'Add your receipt printer to print receipts, bar tickets and shift reports.',
              action: printingSupported
                  ? FilledButton.icon(onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded), label: const Text('Add printer'))
                  : null,
            ),
          )
        else
          for (final p in printers)
            _PrinterCard(
              printer: p,
              testing: _busy.contains('${p.id}test'),
              kicking: _busy.contains('${p.id}drawer'),
              onEdit: () => _edit(p),
              onRemove: () => _remove(p),
              onTest: printingSupported ? () => _test(p) : null,
              onDrawer: printingSupported && p.cashDrawer ? () => _drawer(p) : null,
              onEnabled: (v) => _saveList([for (final x in _list) x.id == p.id ? x.copyWith(enabled: v) : x]),
            ),
        const InfoBanner(
          'USB printers: install the printer in Windows first (Settings › Bluetooth & devices › Printers & scanners, using the driver from the '
          'printer’s maker), then pick it here by name. Network printers only need their IP address (port 9100).',
          title: 'Connecting a printer',
          icon: Icons.lightbulb_outline_rounded,
        ),
      ],
    );
  }
}

class _PrinterCard extends StatelessWidget {
  const _PrinterCard({
    required this.printer,
    required this.testing,
    required this.kicking,
    required this.onEdit,
    required this.onRemove,
    required this.onTest,
    required this.onDrawer,
    required this.onEnabled,
  });
  final PrinterConfig printer;
  final bool testing, kicking;
  final VoidCallback onEdit, onRemove;
  final VoidCallback? onTest, onDrawer;
  final ValueChanged<bool> onEnabled;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = printer;
    Widget spinner() => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Opacity(opacity: p.enabled ? 1 : 0.5, child: IconBadge(icon: Icons.print_rounded, color: ec.primary)),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: context.tt.titleMedium?.copyWith(color: p.enabled ? null : ec.textFaint), overflow: TextOverflow.ellipsis),
              Row(children: [
                Icon(printerKindIcon(p.kind), size: 14, color: ec.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(p.target.isEmpty ? p.kind.label : p.target, style: context.tt.bodySmall, overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
          Tooltip(message: p.enabled ? 'Turn off' : 'Turn on', child: Switch(value: p.enabled, onChanged: onEnabled)),
        ]),
        const SizedBox(height: Sp.md),
        Wrap(spacing: Sp.xs, runSpacing: Sp.xs, children: [
          Pill('${p.paperMm} mm', dense: true),
          Pill(p.kind.label, dense: true),
          for (final r in PrintRole.values)
            if (p.roles.contains(r)) Pill(r.label, dense: true, tone: Tone.primary),
          if (p.cashDrawer) const Pill('Cash drawer', dense: true, tone: Tone.accent, icon: Icons.point_of_sale_rounded),
          if (p.roles.isEmpty) const Pill('No print jobs assigned', dense: true, tone: Tone.warning),
        ]),
        const SizedBox(height: Sp.md),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          OutlinedButton.icon(
            onPressed: testing ? null : onTest,
            icon: testing ? spinner() : const Icon(Icons.receipt_outlined, size: 18),
            label: const Text('Test print'),
          ),
          if (p.cashDrawer)
            OutlinedButton.icon(
              onPressed: kicking ? null : onDrawer,
              icon: kicking ? spinner() : const Icon(Icons.point_of_sale_rounded, size: 18),
              label: const Text('Open drawer'),
            ),
          TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Edit')),
          TextButton.icon(
            onPressed: onRemove,
            style: TextButton.styleFrom(foregroundColor: ec.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Remove'),
          ),
        ]),
      ]),
    );
  }
}

class _PrinterDialog extends StatefulWidget {
  const _PrinterDialog({this.printer, required this.existing});
  final PrinterConfig? printer;
  final List<PrinterConfig> existing;
  @override
  State<_PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<_PrinterDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late PrinterKind _kind;
  late int _paper;
  late Set<PrintRole> _roles;
  late bool _drawer, _nativeQr, _enabled;
  late Future<List<String>> _system;

  @override
  void initState() {
    super.initState();
    final p = widget.printer;
    _kind = p?.kind ?? defaultPrinterKind();
    _name = TextEditingController(text: p?.name ?? (widget.existing.isEmpty ? 'Receipt printer' : 'Bar printer'));
    String host = '', port = '9100';
    if (p != null && p.kind == PrinterKind.network) {
      final i = p.target.lastIndexOf(':');
      if (i > 0) {
        host = p.target.substring(0, i);
        port = p.target.substring(i + 1);
      } else {
        host = p.target;
      }
    }
    _target = TextEditingController(text: p != null && p.kind != PrinterKind.network ? p.target : '');
    _host = TextEditingController(text: host);
    _port = TextEditingController(text: port);
    _paper = p?.paperMm ?? 80;
    _roles = {...(p?.roles ?? (widget.existing.isEmpty ? {PrintRole.receipt, PrintRole.kot, PrintRole.report} : {PrintRole.kot}))};
    _drawer = p?.cashDrawer ?? widget.existing.isEmpty;
    _nativeQr = p?.nativeQr ?? true;
    _enabled = p?.enabled ?? true;
    _system = listSystemPrinters();
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_roles.isEmpty) {
      toast(context, 'Pick at least one print job for this printer', error: true);
      return;
    }
    final target = _kind == PrinterKind.network ? '${_host.text.trim()}:${_port.text.trim().isEmpty ? '9100' : _port.text.trim()}' : _target.text.trim();
    final p = PrinterConfig(
      id: widget.printer?.id ?? newId(),
      name: _name.text.trim(),
      kind: _kind,
      target: target,
      paperMm: _paper,
      roles: _roles,
      cashDrawer: _drawer,
      nativeQr: _nativeQr,
      enabled: _enabled,
    );
    Navigator.pop(context, p);
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final network = _kind == PrinterKind.network;
    return DialogFrame(
      title: widget.printer == null ? 'Add printer' : 'Edit printer',
      icon: Icons.print_outlined,
      actions: dialogActions(context, saveLabel: widget.printer == null ? 'Add printer' : 'Save', onSave: _save),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Counter printer, Bar printer'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
          ),
          fieldGap,
          DropdownButtonFormField<PrinterKind>(
            initialValue: _kind,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Connection'),
            items: [
              for (final k in PrinterKind.values)
                DropdownMenuItem(
                  value: k,
                  child: Row(children: [Icon(printerKindIcon(k), size: 18), const SizedBox(width: Sp.sm), Flexible(child: Text(k.label, overflow: TextOverflow.ellipsis))]),
                ),
            ],
            onChanged: (v) => setState(() => _kind = v ?? _kind),
          ),
          fieldGap,
          if (network)
            FieldRow(breakpoint: 360, flex: const [3, 1], children: [
              TextFormField(
                controller: _host,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'IP address', hintText: '192.168.1.50'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Enter the printer’s IP address';
                  if (t.contains(' ') || t.contains(':')) return 'Enter only the address, without the port';
                  return null;
                },
              ),
              TextFormField(
                controller: _port,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                decoration: const InputDecoration(labelText: 'Port'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return n == null || n < 1 || n > 65535 ? '1 – 65535' : null;
                },
              ),
            ])
          else
            _SystemPrinterField(controller: _target, system: _system, onRefresh: () => setState(() => _system = listSystemPrinters())),
          const SizedBox(height: Sp.lg),
          Text('Paper width', style: context.tt.titleSmall),
          const SizedBox(height: Sp.sm),
          Segments<int>(
            values: const [80, 58],
            selected: _paper,
            minWidth: 240,
            label: (v) => '$v mm',
            onChanged: (v) => setState(() => _paper = v),
          ),
          const SizedBox(height: Sp.lg),
          Text('Prints', style: context.tt.titleSmall),
          for (final r in PrintRole.values)
            CheckboxListTile(
              value: _roles.contains(r),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(r.label, style: context.tt.bodyMedium),
              onChanged: (v) => setState(() => v == true ? _roles.add(r) : _roles.remove(r)),
            ),
          Divider(height: Sp.xl, color: ec.border),
          LabeledSwitch(
            title: 'Cash drawer connected',
            subtitle: 'The drawer’s cable is plugged into this printer',
            value: _drawer,
            onChanged: (v) => setState(() => _drawer = v),
          ),
          LabeledSwitch(
            title: 'Printer draws QR codes',
            subtitle: 'Turn off if the FBR QR code prints as gibberish — it is then sent as an image',
            value: _nativeQr,
            onChanged: (v) => setState(() => _nativeQr = v),
          ),
          LabeledSwitch(title: 'Enabled', value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
        ]),
      ),
    );
  }
}

/// Printer name for Windows / CUPS: pick from the installed printers or type it.
class _SystemPrinterField extends StatelessWidget {
  const _SystemPrinterField({required this.controller, required this.system, required this.onRefresh});
  final TextEditingController controller;
  final Future<List<String>> system;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
        future: system,
        builder: (context, snap) {
          final names = snap.data ?? const <String>[];
          final loading = snap.connectionState != ConnectionState.done;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (names.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                key: ValueKey('sys-${names.length}-${names.contains(controller.text.trim())}'),
                initialValue: names.contains(controller.text.trim()) ? controller.text.trim() : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Installed printers'),
                hint: const Text('Pick a printer installed on this computer'),
                items: [for (final n in names) DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))],
                onChanged: (v) {
                  if (v != null) controller.text = v;
                },
              ),
              fieldGap,
            ],
            TextFormField(
              controller: controller,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Printer name',
                hintText: 'Exactly as shown in Windows, e.g. POS-80',
                helperText: loading
                    ? 'Looking for installed printers…'
                    : (names.isEmpty ? 'No installed printers found — type the name or install the printer first' : 'Or type the name exactly'),
                suffixIcon: IconButton(tooltip: 'Refresh printer list', onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded)),
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Pick or type the printer name' : null,
            ),
          ]);
        },
      );
}
