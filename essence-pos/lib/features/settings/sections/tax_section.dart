import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/money.dart';
import '../../../core/services/repos.dart';
import '../../../core/tax/tax_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

/// The built-in GST row, if present.
TaxRow? builtInGst(List<TaxRow> taxes) => taxes.where((t) => t.builtIn || t.id == 'gst').firstOrNull;

class TaxSection extends ConsumerStatefulWidget {
  const TaxSection({super.key});
  @override
  ConsumerState<TaxSection> createState() => _TaxSectionState();
}

class _TaxSectionState extends SettingsFormState<TaxSection> {
  late final _cash = ctrl();
  late final _card = ctrl();
  bool _gstOn = true;
  bool _inclusive = false;
  int _rounding = 0;

  List<TaxRow> get _taxes => ref.read(taxesProvider).value ?? const [];
  TaxRow? get _gst => builtInGst(_taxes);
  PricingSettings get _pricing => ref.read(settingsValueProvider).pricing;

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider, taxesProvider];

  @override
  Object? savedJson() {
    final g = _gst;
    return {
      'gst': {'enabled': g?.enabled ?? true, 'cash': g?.cashBp ?? 1500, 'card': g?.cardOnlineBp ?? 500},
      'pricing': _pricing.toJson(),
    };
  }

  PricingSettings get _draftPricing => PricingSettings(pricesIncludeTax: _inclusive, cashRoundingRupees: _rounding);

  @override
  Object? draftJson() => {
        'gst': {'enabled': _gstOn, 'cash': parseBp(_cash.text), 'card': parseBp(_card.text)},
        'pricing': _draftPricing.toJson(),
      };

  @override
  void load() {
    final g = _gst;
    _gstOn = g?.enabled ?? true;
    setText(_cash, bpText(g?.cashBp ?? 1500));
    setText(_card, bpText(g?.cardOnlineBp ?? 500));
    _inclusive = _pricing.pricesIncludeTax;
    _rounding = _pricing.cashRoundingRupees;
  }

  @override
  Future<void> persist() async {
    final repo = ref.read(servicesProvider).settingsRepo;
    final cash = parseBp(_cash.text)!;
    final card = parseBp(_card.text)!;
    final g = _gst;
    if (g == null) {
      await repo.saveTax(TaxRow(
        id: 'gst',
        updatedAt: nowMs(),
        deleted: false,
        name: 'GST',
        enabled: _gstOn,
        cashBp: cash,
        cardOnlineBp: card,
        builtIn: true,
        sortOrder: 0,
      ));
    } else if (g.enabled != _gstOn || g.cashBp != cash || g.cardOnlineBp != card || g.name != 'GST') {
      await repo.saveTax(g.copyWith(name: 'GST', enabled: _gstOn, cashBp: cash, cardOnlineBp: card));
    }
    final p = _draftPricing;
    if (p.pricesIncludeTax != _pricing.pricesIncludeTax || p.cashRoundingRupees != _pricing.cashRoundingRupees) {
      await repo.save(SettingKeys.pricing, p.toJson());
    }
  }

  @override
  String get savedMessage => 'Tax settings saved';

  /// Bill configuration reflecting the unsaved GST and pricing edits.
  BillConfig _previewConfig(List<TaxRow> taxes, BillConfig live) {
    final cash = parseBp(_cash.text) ?? 0;
    final card = parseBp(_card.text) ?? 0;
    return BillConfig(
      taxes: [
        if (_gstOn) TaxRule(id: 'gst', name: 'GST', cashBp: cash, cardOnlineBp: card),
        for (final t in taxes)
          if (!t.builtIn && t.id != 'gst' && t.enabled) TaxRule(id: t.id, name: t.name, cashBp: t.cashBp, cardOnlineBp: t.cardOnlineBp),
      ],
      pricesIncludeTax: _inclusive,
      fbrFee: live.fbrFee,
      cashRoundingRupees: _rounding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taxes = ref.watch(taxesProvider).value ?? const <TaxRow>[];
    final others = taxes.where((t) => !t.builtIn && t.id != 'gst').toList();
    final live = ref.watch(billConfigProvider);
    final cashPct = pct(parseBp(_cash.text) ?? 0);
    final cardPct = pct(parseBp(_card.text) ?? 0);

    return SettingsScaffold(
      title: 'Tax',
      subtitle: 'GST is charged at a different rate for cash and for card / online payments.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'GST',
          subtitle: 'Built-in sales tax. The name is fixed and it can’t be deleted.',
          icon: Icons.account_balance_outlined,
          trailing: const Pill('Built-in', tone: Tone.primary, dense: true),
          children: [
            LabeledSwitch(
              title: 'Enable GST',
              subtitle: _gstOn ? 'GST is charged on every taxable sale' : 'No GST is charged',
              value: _gstOn,
              onChanged: (v) => setState(() => _gstOn = v),
            ),
            const SizedBox(height: Sp.sm),
            FieldRow(breakpoint: 400, children: [
              _PctField(controller: _cash, label: 'Cash', icon: Icons.payments_outlined, enabled: _gstOn),
              _PctField(controller: _card, label: 'Card / Online', icon: Icons.credit_card_rounded, enabled: _gstOn),
            ]),
            const SizedBox(height: Sp.sm),
            Text(
              'Card / Online covers every payment method in the Card / Online group (cards, JazzCash, Easypaisa, bank transfer…). '
              'Decimals like 7.5 are allowed.',
              style: context.tt.bodySmall,
            ),
          ],
        ),
        SettingsCard(
          title: 'Other taxes',
          subtitle: 'Extra taxes charged on top of GST, each with its own cash and card / online rate.',
          icon: Icons.add_chart_outlined,
          trailing: OutlinedButton.icon(
            onPressed: () => _editTax(context, null, others),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
          ),
          children: [
            if (others.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Sp.sm),
                child: Text('No other taxes. Most cafés only need GST.', style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted)),
              )
            else
              for (var i = 0; i < others.length; i++) ...[
                if (i > 0) const Divider(height: Sp.lg),
                _OtherTaxRow(tax: others[i], onEdit: () => _editTax(context, others[i], others)),
              ],
          ],
        ),
        SettingsCard(
          title: 'Pricing',
          icon: Icons.sell_outlined,
          children: [
            LabeledSwitch(
              title: 'Menu prices include tax',
              subtitle: _inclusive
                  ? 'The bill total equals the menu prices. The receipt shows the tax already inside it at the paying method’s rate '
                      '(e.g. “incl. GST $cashPct” for cash, “incl. GST $cardPct” for card / online).'
                  : 'Menu prices are before tax. Tax is added on top at checkout at the paying method’s rate '
                      '(+$cashPct for cash, +$cardPct for card / online).',
              value: _inclusive,
              onChanged: (v) => setState(() => _inclusive = v),
            ),
            const Divider(height: Sp.xl),
            Text('Cash rounding', style: context.tt.titleSmall),
            const SizedBox(height: 2),
            Text(
              _rounding == 0
                  ? 'Cash totals are charged to the exact rupee.'
                  : 'Cash totals are rounded to the nearest Rs $_rounding. Card / online payments are never rounded.',
              style: context.tt.bodySmall,
            ),
            const SizedBox(height: Sp.sm),
            Segments<int>(
              values: const [0, 1, 5, 10],
              selected: _rounding,
              minWidth: 300,
              label: (v) => v == 0 ? 'None' : 'Rs $v',
              onChanged: (v) => setState(() => _rounding = v),
            ),
          ],
        ),
        _ExampleCard(config: _previewConfig(taxes, live)),
        InfoBanner(
          'Products that are exempt from tax (e.g. bottled water) are marked individually in Menu.',
          icon: Icons.restaurant_menu_rounded,
          action: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                if (await confirmLeave(context, ref) && context.mounted) context.go('/settings/menu');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Open Menu'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editTax(BuildContext context, TaxRow? tax, List<TaxRow> others) async {
    await showAdaptive<void>(context, maxWidth: 480, builder: (_) => _TaxDialog(tax: tax, nextSort: others.fold(1, (a, t) => t.sortOrder >= a ? t.sortOrder + 1 : a)));
  }
}

class _PctField extends StatelessWidget {
  const _PctField({required this.controller, required this.label, required this.icon, this.enabled = true});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: decimalInput,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(labelText: label, suffixText: '%', prefixIcon: Icon(icon, size: 20)),
        validator: pctValidator,
      );
}

class _OtherTaxRow extends ConsumerWidget {
  const _OtherTaxRow({required this.tax, required this.onEdit});
  final TaxRow tax;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(servicesProvider).settingsRepo;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tax.name, style: context.tt.titleSmall?.copyWith(color: tax.enabled ? null : context.ec.textFaint)),
          const SizedBox(height: Sp.xs),
          Wrap(spacing: Sp.xs, runSpacing: Sp.xs, children: [
            Pill('Cash ${pct(tax.cashBp)}', dense: true, tone: tax.enabled ? Tone.accent : Tone.neutral),
            Pill('Card / Online ${pct(tax.cardOnlineBp)}', dense: true, tone: tax.enabled ? Tone.info : Tone.neutral),
          ]),
        ]),
      ),
      Tooltip(
        message: tax.enabled ? 'Disable' : 'Enable',
        child: Switch(value: tax.enabled, onChanged: (v) => repo.saveTax(tax.copyWith(enabled: v))),
      ),
      IconButton(tooltip: 'Edit ${tax.name}', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
    ]);
  }
}

class _TaxDialog extends ConsumerStatefulWidget {
  const _TaxDialog({this.tax, required this.nextSort});
  final TaxRow? tax;
  final int nextSort;
  @override
  ConsumerState<_TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends ConsumerState<_TaxDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.tax?.name ?? '');
  late final _cash = TextEditingController(text: widget.tax == null ? '' : bpText(widget.tax!.cashBp));
  late final _card = TextEditingController(text: widget.tax == null ? '' : bpText(widget.tax!.cardOnlineBp));
  late bool _enabled = widget.tax?.enabled ?? true;

  @override
  void dispose() {
    _name.dispose();
    _cash.dispose();
    _card.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final repo = ref.read(servicesProvider).settingsRepo;
    final t = widget.tax;
    final name = _name.text.trim();
    final cash = parseBp(_cash.text)!;
    final card = parseBp(_card.text)!;
    if (t == null) {
      await repo.saveTax(TaxRow(
        id: newId(),
        updatedAt: nowMs(),
        deleted: false,
        name: name,
        enabled: _enabled,
        cashBp: cash,
        cardOnlineBp: card,
        builtIn: false,
        sortOrder: widget.nextSort,
      ));
    } else {
      await repo.saveTax(t.copyWith(name: name, enabled: _enabled, cashBp: cash, cardOnlineBp: card));
    }
    if (!mounted) return;
    Navigator.pop(context);
    toast(context, t == null ? '$name added' : '$name saved');
  }

  Future<void> _delete() async {
    final t = widget.tax!;
    final ok = await confirm(context, title: 'Delete ${t.name}?', message: 'It will no longer be charged on new sales. Past invoices are not changed.', confirmLabel: 'Delete', destructive: true);
    if (!ok || !mounted) return;
    await ref.read(servicesProvider).settingsRepo.deleteTax(t);
    if (!mounted) return;
    Navigator.pop(context);
    toast(context, '${t.name} deleted');
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.tax != null;
    return DialogFrame(
      title: editing ? 'Edit tax' : 'Add tax',
      icon: Icons.percent_rounded,
      actions: [
        if (editing)
          TextButton.icon(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: context.ec.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete'),
          ),
        ...dialogActions(context, saveLabel: editing ? 'Save' : 'Add tax', onSave: _save),
      ],
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _name,
            autofocus: !editing,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Tax name', hintText: 'e.g. Provincial sales tax'),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Enter a name';
              if (t.toLowerCase() == 'gst') return 'GST is built in — edit it above';
              return null;
            },
          ),
          fieldGap,
          FieldRow(breakpoint: 360, children: [
            _PctField(controller: _cash, label: 'Cash', icon: Icons.payments_outlined),
            _PctField(controller: _card, label: 'Card / Online', icon: Icons.credit_card_rounded),
          ]),
          const SizedBox(height: Sp.sm),
          LabeledSwitch(title: 'Enabled', subtitle: 'Charge this tax on new sales', value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
        ]),
      ),
    );
  }
}

/// A worked example of a Rs 1,850 order paid by cash and by card, using the draft settings.
class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.config});
  final BillConfig config;

  static const _lines = [
    BillLine(key: 'cake', unitPrice: 130000, qty: 1),
    BillLine(key: 'coffee', unitPrice: 55000, qty: 1),
  ];

  @override
  Widget build(BuildContext context) {
    BillResult bill(RateGroup g) => computeBill(
          lines: _lines,
          config: config,
          portions: [PaymentPortionInput(methodId: g.name, methodName: g.label, group: g)],
        );
    final cash = bill(RateGroup.cash);
    final card = bill(RateGroup.cardOnline);
    return SettingsCard(
      title: 'Worked example',
      subtitle: 'Cheesecake Rs 1,300 + Cappuccino Rs 550 = Rs 1,850 on the menu. Updates as you edit.',
      icon: Icons.calculate_outlined,
      children: [
        FieldRow(breakpoint: 440, children: [
          _ExampleColumn(title: 'Paid by cash', icon: Icons.payments_outlined, bill: cash),
          _ExampleColumn(title: 'Paid by card / online', icon: Icons.credit_card_rounded, bill: card),
        ]),
        const SizedBox(height: Sp.md),
        Text(
          config.pricesIncludeTax
              ? 'Prices include tax: the customer pays the menu price; the tax shown is the part of it that goes to FBR.'
              : 'Prices exclude tax: the tax is added on top of the menu price.',
          style: context.tt.bodySmall,
        ),
      ],
    );
  }
}

class _ExampleColumn extends StatelessWidget {
  const _ExampleColumn({required this.title, required this.icon, required this.bill});
  final String title;
  final IconData icon;
  final BillResult bill;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final incl = bill.pricesIncludeTax;
    Widget row(String l, String r, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: Text(l, style: (bold ? context.tt.titleSmall : context.tt.bodyMedium)?.copyWith(color: color ?? (bold ? null : ec.textMuted)))),
            Text(r, style: (bold ? context.tt.titleMedium : context.tt.bodyMedium)?.copyWith(fontFeatures: tabular, color: color)),
          ]),
        );
    final taxes = bill.portions.isEmpty ? const <TaxAmount>[] : bill.portions.first.taxes;
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(Rad.md)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(icon, size: 18, color: ec.accent),
          const SizedBox(width: Sp.sm),
          Expanded(child: Text(title, style: context.tt.titleSmall)),
        ]),
        const SizedBox(height: Sp.sm),
        row('Menu prices', rs(bill.itemsGross)),
        if (!incl)
          for (final t in taxes) row('+ ${t.name} ${pct(t.rateBp)}', rs(t.amount)),
        if (taxes.isEmpty) row('Tax', 'none'),
        if (bill.fbrFee > 0) row('+ FBR POS fee', rs(bill.fbrFee)),
        if (bill.rounding != 0) row('Rounding', rs(bill.rounding)),
        Divider(height: Sp.lg, color: ec.border),
        row('Total', rs(bill.total), bold: true),
        if (incl)
          for (final t in taxes) row('incl. ${t.name} ${pct(t.rateBp)}', rs(t.amount), color: ec.textMuted),
      ]),
    );
  }
}
