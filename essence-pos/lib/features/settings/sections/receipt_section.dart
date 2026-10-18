import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/order_models.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/printing/printer_config.dart';
import '../../../core/printing/templates.dart';
import '../../../core/tax/tax_engine.dart';
import '../../../shared/common.dart';
import '../../../shared/receipt_preview.dart';
import '../settings_widgets.dart';

/// An in-memory paid takeaway order used for receipt previews.
Order sampleOrder({
  required AppSettings settings,
  required BillConfig config,
  required String deviceId,
  required String deviceCode,
  required String staffName,
  required String businessDate,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final lines = [
    const OrderLine(
      key: 'l1',
      productId: 'sample-cappuccino',
      categoryId: 'hot',
      name: 'Cappuccino',
      basePrice: 55000,
      size: ProductSize(code: 'L', label: 'Large', delta: 10000),
      modifiers: [SelectedModifier(groupId: 'milk', groupName: 'Milk', option: ModifierOption(id: 'oat', name: 'Oat milk', delta: 15000))],
      qty: 2,
    ),
    const OrderLine(key: 'l2', productId: 'sample-cheesecake', categoryId: 'cakes', name: 'Lotus Cheesecake', basePrice: 130000),
    const OrderLine(key: 'l3', productId: 'sample-croissant', categoryId: 'bakery', name: 'Almond Croissant', basePrice: 65000),
  ];
  final bill = computeBill(
    lines: [for (final l in lines) l.toBillLine()],
    config: config,
    portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
  );
  final nets = {for (final l in bill.lines) l.key: l.net};
  final total = bill.total;
  final tendered = ((total + 49999) ~/ 50000) * 50000;
  final portion = bill.portions.isEmpty ? null : bill.portions.first;
  final payment = PaymentRecord(
    methodId: 'cash',
    methodName: 'Cash',
    group: RateGroup.cash,
    amount: total,
    tendered: tendered,
    change: tendered - total,
    taxes: portion?.taxes ?? const [],
  );
  final fbr = settings.fbr.enabled;
  final posId = settings.fbr.posId.trim().isEmpty ? '137284' : settings.fbr.posId.trim();
  return Order(
    id: 'sample',
    updatedAt: now,
    deleted: false,
    number: '${settings.store.invoicePrefix}-$deviceCode-000123',
    token: 12,
    businessDate: businessDate,
    orderType: OrderType.takeaway.key,
    status: OrderStatus.paid,
    linesJson: jsonEncode([for (final l in lines) l.copyWith(net: nets[l.key] ?? l.gross).toJson()]),
    chargesJson: jsonEncode([
      for (final c in bill.charges) ChargeRecord(type: c.type.name, label: c.label, amount: c.amount, taxable: c.taxable).toJson(),
    ]),
    taxLinesJson: jsonEncode([for (final t in bill.taxLines) t.toJson()]),
    paymentsJson: jsonEncode([payment.toJson()]),
    pricesIncludeTax: config.pricesIncludeTax,
    itemsGross: bill.itemsGross,
    discountTotal: bill.discountTotal,
    chargesTotal: bill.chargesTotal,
    taxTotal: bill.taxTotal,
    fbrFee: bill.fbrFee,
    rounding: bill.rounding,
    total: total,
    netExTax: bill.netExTax,
    refundedTotal: 0,
    staffId: 'sample',
    staffName: staffName,
    deviceId: deviceId,
    deviceCode: deviceCode,
    kotSent: true,
    fiscalStatus: fbr ? 'reported' : 'none',
    fiscalInvoiceNo: fbr ? '$posId-1016-1432-120' : null,
    fiscalAt: fbr ? now : null,
    createdAt: now,
    paidAt: now,
  );
}

class ReceiptSection extends ConsumerStatefulWidget {
  const ReceiptSection({super.key});
  @override
  ConsumerState<ReceiptSection> createState() => _ReceiptSectionState();
}

class _ReceiptSectionState extends SettingsFormState<ReceiptSection> {
  late final _header = ctrl();
  late final _footer = ctrl();
  bool _logo = true, _taxBreakdown = true, _cashier = true, _token = true, _autoPrint = true, _kot = true;
  int _copies = 1, _kotCopies = 1;
  int? _paperMm;

  ReceiptSettings get _saved => ref.read(settingsValueProvider).receipt;

  ReceiptSettings get _draft => ReceiptSettings(
        header: _header.text.trim(),
        footer: _footer.text.trim(),
        showLogo: _logo,
        showTaxBreakdown: _taxBreakdown,
        showCashier: _cashier,
        showToken: _token,
        autoPrintReceipt: _autoPrint,
        receiptCopies: _copies,
        printKotOnPay: _kot,
        kotCopies: _kotCopies,
      );

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  @override
  Object? draftJson() => _draft.toJson();

  @override
  void load() {
    final s = _saved;
    setText(_header, s.header);
    setText(_footer, s.footer);
    _logo = s.showLogo;
    _taxBreakdown = s.showTaxBreakdown;
    _cashier = s.showCashier;
    _token = s.showToken;
    _autoPrint = s.autoPrintReceipt;
    _copies = s.receiptCopies.clamp(1, 3);
    _kot = s.printKotOnPay;
    _kotCopies = s.kotCopies.clamp(1, 3);
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.receipt, _draft.toJson());

  @override
  String get savedMessage => 'Receipt settings saved';

  @override
  Widget build(BuildContext context) {
    final form = _form(context);
    final preview = _preview(context);
    return SettingsScaffold(
      title: 'Receipt',
      subtitle: 'What prints on the customer receipt and when tickets print.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        LayoutBuilder(builder: (context, c) {
          if (c.maxWidth >= 720) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: form),
              const SizedBox(width: Sp.lg),
              SizedBox(width: 320, child: preview),
            ]);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [form, const SizedBox(height: Sp.lg), preview]);
        }),
      ],
    );
  }

  Widget _form(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SettingsCard(
          title: 'Text',
          icon: Icons.notes_rounded,
          children: [
            TextFormField(
              controller: _header,
              minLines: 1,
              maxLines: 4,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Header text', hintText: 'Printed under the store details, e.g. opening hours'),
            ),
            fieldGap,
            TextFormField(
              controller: _footer,
              minLines: 2,
              maxLines: 5,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Footer text', hintText: 'Thank you for visiting!'),
            ),
          ],
        ),
        const SizedBox(height: Sp.lg),
        SettingsCard(
          title: 'Show on the receipt',
          icon: Icons.visibility_outlined,
          children: [
            LabeledSwitch(title: 'Logo', subtitle: 'Otherwise the store name prints in large letters', value: _logo, onChanged: (v) => setState(() => _logo = v)),
            LabeledSwitch(title: 'Tax breakdown', subtitle: 'Tax included and the value excluding tax', value: _taxBreakdown, onChanged: (v) => setState(() => _taxBreakdown = v)),
            LabeledSwitch(title: 'Cashier name', value: _cashier, onChanged: (v) => setState(() => _cashier = v)),
            LabeledSwitch(title: 'Token number', subtitle: 'For calling out orders at the counter', value: _token, onChanged: (v) => setState(() => _token = v)),
          ],
        ),
        const SizedBox(height: Sp.lg),
        SettingsCard(
          title: 'Printing',
          icon: Icons.print_outlined,
          children: [
            LabeledSwitch(title: 'Print receipt after payment', value: _autoPrint, onChanged: (v) => setState(() => _autoPrint = v)),
            _CopiesRow(label: 'Receipt copies', value: _copies, enabled: _autoPrint, onChanged: (v) => setState(() => _copies = v)),
            const Divider(height: Sp.xl),
            LabeledSwitch(
              title: 'Print bar ticket (KOT) on payment',
              subtitle: 'Sends the order to the bar / kitchen printer',
              value: _kot,
              onChanged: (v) => setState(() => _kot = v),
            ),
            _CopiesRow(label: 'KOT copies', value: _kotCopies, enabled: _kot, onChanged: (v) => setState(() => _kotCopies = v)),
          ],
        ),
      ]);

  Widget _preview(BuildContext context) {
    final s = ref.watch(settingsValueProvider);
    final svc = ref.watch(servicesProvider);
    final printers = ref.watch(printersProvider).value ?? const <PrinterConfig>[];
    final receiptPrinter = printers.where((p) => p.enabled && p.roles.contains(PrintRole.receipt)).firstOrNull;
    final paper = _paperMm ?? receiptPrinter?.paperMm ?? 80;
    final draftSettings = AppSettings(
      store: s.store,
      pricing: s.pricing,
      orderTypes: s.orderTypes,
      charges: s.charges,
      discounts: s.discounts,
      receipt: _draft,
      fbr: s.fbr,
      security: s.security,
      permissions: s.permissions,
    );
    final order = sampleOrder(
      settings: draftSettings,
      config: ref.watch(billConfigProvider),
      deviceId: svc.device.id,
      deviceCode: svc.device.code,
      staffName: ref.watch(sessionProvider)?.name ?? 'Cashier',
      businessDate: svc.ctx.businessDate(),
    );
    final doc = buildReceipt(order, draftSettings);
    return SettingsCard(
      title: 'Preview',
      subtitle: 'Sample order, updates as you edit',
      padding: const EdgeInsets.all(Sp.lg),
      children: [
        Segments<int>(
          values: const [80, 58],
          selected: paper,
          minWidth: 200,
          label: (v) => '$v mm',
          onChanged: (v) => setState(() => _paperMm = v),
        ),
        const SizedBox(height: Sp.lg),
        Container(
          padding: const EdgeInsets.symmetric(vertical: Sp.lg, horizontal: Sp.sm),
          decoration: BoxDecoration(color: context.ec.beige, borderRadius: BorderRadius.circular(Rad.md)),
          child: ReceiptPreview(doc: doc, columns: paper >= 80 ? 48 : 32, maxWidth: paper >= 80 ? 340 : 250),
        ),
      ],
    );
  }
}

class _CopiesRow extends StatelessWidget {
  const _CopiesRow({required this.label, required this.value, required this.enabled, required this.onChanged});
  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.xs),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Row(children: [
            Expanded(child: Text(label, style: context.tt.titleSmall)),
            IgnorePointer(ignoring: !enabled, child: QtyStepper(value: value, min: 1, max: 3, compact: true, onChanged: onChanged)),
          ]),
        ),
      );
}
