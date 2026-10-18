import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/money.dart';
import '../../../core/services/repos.dart';
import '../../../core/tax/tax_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';
import 'tax_section.dart';

/// "GST 15%" for a rate group, or "No GST".
String gstLabelFor(List<TaxRow> taxes, RateGroup g) {
  final gst = builtInGst(taxes);
  if (gst == null || !gst.enabled) return 'No GST';
  return 'GST ${pct(g == RateGroup.cash ? gst.cashBp : gst.cardOnlineBp)}';
}

class PaymentsSection extends ConsumerWidget {
  const PaymentsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(paymentMethodsProvider);
    final methods = async.value ?? const <PaymentMethod>[];
    final taxes = ref.watch(taxesProvider).value ?? const <TaxRow>[];

    return SettingsScaffold(
      title: 'Payment methods',
      subtitle: 'What customers can pay with. Each method belongs to a GST rate group.',
      actions: [
        FilledButton.icon(
          onPressed: () => _edit(context, null, methods),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add method'),
        ),
      ],
      children: [
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          Pill('Cash group · ${gstLabelFor(taxes, RateGroup.cash)}', tone: Tone.accent, icon: Icons.payments_outlined),
          Pill('Card / Online group · ${gstLabelFor(taxes, RateGroup.cardOnline)}', tone: Tone.info, icon: Icons.credit_card_rounded),
        ]),
        if (async.isLoading && methods.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(Sp.xl), child: CircularProgressIndicator()))
        else if (methods.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.payments_outlined,
              title: 'No payment methods',
              message: 'Add at least Cash so the till can take payments.',
              action: FilledButton.icon(onPressed: () => _edit(context, null, methods), icon: const Icon(Icons.add_rounded), label: const Text('Add method')),
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < methods.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.ec.border),
                _MethodTile(
                  method: methods[i],
                  index: i,
                  methods: methods,
                  gstLabel: gstLabelFor(taxes, RateGroup.parse(methods[i].rateGroup)),
                  onEdit: () => _edit(context, methods[i], methods),
                ),
              ],
            ]),
          ),
        Text(
          'Methods that open the cash drawer kick it open when the receipt prints. The order here is the order of the buttons at checkout.',
          style: context.tt.bodySmall,
        ),
      ],
    );
  }

  static Future<void> _edit(BuildContext context, PaymentMethod? m, List<PaymentMethod> all) =>
      showAdaptive<void>(context, maxWidth: 520, builder: (_) => _MethodDialog(method: m, all: all));
}

/// Writes new sort orders after moving [from] to [to].
Future<void> _reorder(SettingsRepo repo, List<PaymentMethod> methods, int from, int to) async {
  final list = [...methods];
  final m = list.removeAt(from);
  list.insert(to, m);
  for (var i = 0; i < list.length; i++) {
    if (list[i].sortOrder != i) await repo.savePaymentMethod(list[i].copyWith(sortOrder: i));
  }
}

class _MethodTile extends ConsumerWidget {
  const _MethodTile({required this.method, required this.index, required this.methods, required this.gstLabel, required this.onEdit});
  final PaymentMethod method;
  final int index;
  final List<PaymentMethod> methods;
  final String gstLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final repo = ref.read(servicesProvider).settingsRepo;
    final group = RateGroup.parse(method.rateGroup);
    final activeCount = methods.where((m) => m.active).length;

    Future<void> setActive(bool v) async {
      if (!v && activeCount <= 1) {
        toast(context, 'Keep at least one payment method active', error: true);
        return;
      }
      await repo.savePaymentMethod(method.copyWith(active: v));
    }

    Future<void> delete() async {
      final ok = await confirm(context,
          title: 'Delete ${method.name}?', message: 'It disappears from checkout. Past payments keep their method name.', confirmLabel: 'Delete', destructive: true);
      if (!ok) return;
      await repo.deletePaymentMethod(method);
      if (context.mounted) toast(context, '${method.name} deleted');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.sm, Sp.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Opacity(opacity: method.active ? 1 : 0.5, child: IconBadge(icon: iconFor(method.icon, fallback: Icons.payments_rounded), color: group == RateGroup.cash ? ec.accent : ec.info)),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: Sp.sm, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(method.name, style: context.tt.titleSmall?.copyWith(color: method.active ? null : ec.textFaint)),
                if (method.builtIn) const Pill('Built-in', dense: true),
                if (!method.active) const Pill('Hidden', dense: true, tone: Tone.warning),
              ]),
              const SizedBox(height: 2),
              Text('${group.label} rate', style: context.tt.bodySmall),
            ]),
          ),
          Pill(gstLabel, dense: true, tone: group == RateGroup.cash ? Tone.accent : Tone.info),
          PopupMenuButton<String>(
            tooltip: 'More for ${method.name}',
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  onEdit();
                case 'delete':
                  delete();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
              if (!method.builtIn)
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: ec.danger), title: Text('Delete', style: TextStyle(color: ec.danger))),
                ),
            ],
          ),
        ]),
        const SizedBox(height: Sp.sm),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Wrap(spacing: Sp.lg, runSpacing: Sp.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SegmentedButton<RateGroup>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: RateGroup.cash, label: Text('Cash')),
                ButtonSegment(value: RateGroup.cardOnline, label: Text('Card / Online')),
              ],
              selected: {group},
              onSelectionChanged: method.builtIn ? null : (s) => repo.savePaymentMethod(method.copyWith(rateGroup: s.first.name)),
            ),
            _InlineSwitch(label: 'Opens drawer', value: method.opensDrawer, onChanged: (v) => repo.savePaymentMethod(method.copyWith(opensDrawer: v))),
            _InlineSwitch(label: 'Active', value: method.active, onChanged: setActive),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                tooltip: 'Move up',
                onPressed: index > 0 ? () => _reorder(repo, methods, index, index - 1) : null,
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
              IconButton(
                tooltip: 'Move down',
                onPressed: index < methods.length - 1 ? () => _reorder(repo, methods, index, index + 1) : null,
                icon: const Icon(Icons.arrow_downward_rounded, size: 20),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _InlineSwitch extends StatelessWidget {
  const _InlineSwitch({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        toggled: value,
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.sm),
          onTap: () => onChanged(!value),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: context.tt.labelLarge?.copyWith(color: context.ec.textMuted)),
            const SizedBox(width: Sp.xs),
            Switch(value: value, onChanged: onChanged),
          ]),
        ),
      );
}

class _MethodDialog extends ConsumerStatefulWidget {
  const _MethodDialog({this.method, required this.all});
  final PaymentMethod? method;
  final List<PaymentMethod> all;
  @override
  ConsumerState<_MethodDialog> createState() => _MethodDialogState();
}

class _MethodDialogState extends ConsumerState<_MethodDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.method?.name ?? '');
  late String _icon = widget.method?.icon ?? 'card';
  late RateGroup _group = widget.method == null ? RateGroup.cardOnline : RateGroup.parse(widget.method!.rateGroup);
  late bool _drawer = widget.method?.opensDrawer ?? false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final repo = ref.read(servicesProvider).settingsRepo;
    final m = widget.method;
    final name = _name.text.trim();
    if (m == null) {
      await repo.savePaymentMethod(PaymentMethod(
        id: newId(),
        updatedAt: nowMs(),
        deleted: false,
        name: name,
        rateGroup: _group.name,
        icon: _icon,
        opensDrawer: _drawer,
        active: true,
        builtIn: false,
        sortOrder: widget.all.fold(0, (a, x) => x.sortOrder >= a ? x.sortOrder + 1 : a),
      ));
    } else {
      await repo.savePaymentMethod(m.copyWith(name: name, rateGroup: m.builtIn ? m.rateGroup : _group.name, icon: _icon, opensDrawer: _drawer));
    }
    if (!mounted) return;
    Navigator.pop(context);
    toast(context, m == null ? '$name added' : '$name saved');
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final m = widget.method;
    final taxes = ref.watch(taxesProvider).value ?? const <TaxRow>[];
    return DialogFrame(
      title: m == null ? 'Add payment method' : 'Edit ${m.name}',
      icon: Icons.payments_outlined,
      actions: dialogActions(context, saveLabel: m == null ? 'Add method' : 'Save', onSave: _save),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _name,
            autofocus: m == null,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. SadaPay, Card (HBL)'),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Enter a name';
              final dup = widget.all.any((x) => x.id != m?.id && x.name.trim().toLowerCase() == t.toLowerCase());
              return dup ? 'A method with this name already exists' : null;
            },
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: Sp.lg),
          Text('Icon', style: context.tt.titleSmall),
          const SizedBox(height: Sp.sm),
          Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            for (final k in paymentIconKeys)
              Tooltip(
                message: k,
                child: ChoiceChip(
                  label: Icon(iconFor(k), size: 22, color: k == _icon ? ec.onPrimaryContainer : ec.textMuted),
                  selected: k == _icon,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _icon = k),
                ),
              ),
          ]),
          const SizedBox(height: Sp.lg),
          Text('GST rate group', style: context.tt.titleSmall),
          const SizedBox(height: Sp.sm),
          Segments<RateGroup>(
            values: RateGroup.values,
            selected: _group,
            enabled: m?.builtIn != true,
            minWidth: 300,
            label: (g) => '${g.label} · ${gstLabelFor(taxes, g)}',
            onChanged: (g) => setState(() => _group = g),
          ),
          if (m?.builtIn == true)
            Padding(
              padding: const EdgeInsets.only(top: Sp.xs),
              child: Text('Cash always uses the cash rate.', style: context.tt.bodySmall),
            ),
          const SizedBox(height: Sp.sm),
          LabeledSwitch(
            title: 'Opens the cash drawer',
            subtitle: 'Kick the drawer open when this method is used',
            value: _drawer,
            onChanged: (v) => setState(() => _drawer = v),
          ),
        ]),
      ),
    );
  }
}
