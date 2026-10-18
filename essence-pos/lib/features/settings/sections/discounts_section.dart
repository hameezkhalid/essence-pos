import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/money.dart';
import '../../../core/tax/tax_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

class DiscountsSection extends ConsumerStatefulWidget {
  const DiscountsSection({super.key});
  @override
  ConsumerState<DiscountsSection> createState() => _DiscountsSectionState();
}

class _DiscountsSectionState extends SettingsFormState<DiscountsSection> {
  late final _max = ctrl();
  List<Discount> _presets = const [];
  bool _requireReason = true;

  DiscountSettings get _saved => ref.read(settingsValueProvider).discounts;

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  @override
  Object? draftJson() => {
        'presets': _presets.map((d) => d.toJson()).toList(),
        'cashierMaxBp': parseBp(_max.text),
        'requireReason': _requireReason,
      };

  @override
  void load() {
    final s = _saved;
    _presets = [...s.presets];
    _requireReason = s.requireReason;
    setText(_max, bpText(s.cashierMaxBp));
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(
        SettingKeys.discounts,
        DiscountSettings(presets: _presets, cashierMaxBp: parseBp(_max.text)!, requireReason: _requireReason).toJson(),
      );

  @override
  String get savedMessage => 'Discount settings saved';

  Future<void> _edit(int? index) async {
    final d = await showAdaptive<Discount>(context, maxWidth: 460, builder: (_) => _PresetDialog(initial: index == null ? null : _presets[index]));
    if (d == null || !mounted) return;
    setState(() {
      final l = [..._presets];
      index == null ? l.add(d) : l[index] = d;
      _presets = l;
    });
  }

  void _remove(int i) => setState(() => _presets = [..._presets]..removeAt(i));

  void _move(int i, int to) => setState(() {
        final l = [..._presets];
        final d = l.removeAt(i);
        l.insert(to, d);
        _presets = l;
      });

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final maxBp = parseBp(_max.text) ?? 0;
    return SettingsScaffold(
      title: 'Discounts',
      subtitle: 'Quick discount buttons at checkout, and how much a cashier may give on their own.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Preset discounts',
          subtitle: 'Shown as one-tap buttons on the discount sheet.',
          icon: Icons.local_offer_outlined,
          trailing: OutlinedButton.icon(onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add')),
          children: [
            if (_presets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Sp.sm),
                child: Text('No presets. Cashiers can still type a custom discount.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
              )
            else
              for (var i = 0; i < _presets.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ec.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Sp.xs),
                  child: Row(children: [
                    IconBadge(
                      icon: _presets[i].kind == DiscountKind.percent ? Icons.percent_rounded : Icons.money_off_rounded,
                      color: ec.accent,
                      size: 36,
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_presets[i].label ?? _presets[i].display, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
                        Text('${_presets[i].display} off the bill', style: context.tt.bodySmall),
                      ]),
                    ),
                    if (_presets[i].kind == DiscountKind.percent && _presets[i].value > maxBp)
                      const Padding(padding: EdgeInsets.only(right: Sp.xs), child: Pill('Needs PIN', dense: true, tone: Tone.warning)),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      onSelected: (v) {
                        if (v == 'edit') _edit(i);
                        if (v == 'up') _move(i, i - 1);
                        if (v == 'down') _move(i, i + 1);
                        if (v == 'delete') _remove(i);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                        PopupMenuItem(value: 'up', enabled: i > 0, child: const ListTile(leading: Icon(Icons.arrow_upward_rounded), title: Text('Move up'))),
                        PopupMenuItem(
                          value: 'down',
                          enabled: i < _presets.length - 1,
                          child: const ListTile(leading: Icon(Icons.arrow_downward_rounded), title: Text('Move down')),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: ec.danger), title: Text('Remove', style: TextStyle(color: ec.danger))),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
          ],
        ),
        SettingsCard(
          title: 'Cashier limits',
          icon: Icons.verified_user_outlined,
          children: [
            SizedBox(
              width: 280,
              child: TextFormField(
                controller: _max,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: decimalInput,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Max discount without manager PIN', suffixText: '%'),
                validator: pctValidator,
                onFieldSubmitted: (_) => save(),
              ),
            ),
            const SizedBox(height: Sp.sm),
            Text(
              maxBp == 0
                  ? 'Every discount needs a manager’s PIN.'
                  : 'Cashiers can give up to ${pct(maxBp)} of the bill. Anything bigger asks for a manager’s PIN.',
              style: context.tt.bodySmall,
            ),
            const Divider(height: Sp.xl),
            LabeledSwitch(
              title: 'Require a reason',
              subtitle: 'The reason is saved in the activity log with the discount',
              value: _requireReason,
              onChanged: (v) => setState(() => _requireReason = v),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetDialog extends StatefulWidget {
  const _PresetDialog({this.initial});
  final Discount? initial;
  @override
  State<_PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<_PresetDialog> {
  final _form = GlobalKey<FormState>();
  late DiscountKind _kind = widget.initial?.kind ?? DiscountKind.percent;
  late final _label = TextEditingController(text: widget.initial?.label ?? '');
  late final _value = TextEditingController(
    text: widget.initial == null ? '' : (widget.initial!.kind == DiscountKind.percent ? bpText(widget.initial!.value) : rupeeText(widget.initial!.value)),
  );

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  int? get _parsed => _kind == DiscountKind.percent ? parseBp(_value.text) : parseRupees(_value.text);

  void _done() {
    if (!_form.currentState!.validate()) return;
    final v = _parsed!;
    final label = _label.text.trim();
    final d = Discount(kind: _kind, value: v);
    Navigator.pop(context, Discount(kind: _kind, value: v, label: label.isEmpty ? d.display : label));
  }

  @override
  Widget build(BuildContext context) {
    final percent = _kind == DiscountKind.percent;
    return DialogFrame(
      title: widget.initial == null ? 'Add preset' : 'Edit preset',
      icon: Icons.local_offer_outlined,
      actions: dialogActions(context, saveLabel: 'Done', onSave: _done),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Segments<DiscountKind>(
            values: DiscountKind.values,
            selected: _kind,
            minWidth: 260,
            icon: (k) => k == DiscountKind.percent ? Icons.percent_rounded : Icons.payments_outlined,
            label: (k) => k == DiscountKind.percent ? 'Percent' : 'Amount (Rs)',
            onChanged: (k) => setState(() {
              _kind = k;
              _form.currentState?.validate();
            }),
          ),
          const SizedBox(height: Sp.lg),
          TextFormField(
            controller: _value,
            autofocus: widget.initial == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInput,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: percent ? 'Discount' : 'Amount off',
              suffixText: percent ? '%' : null,
              prefixText: percent ? null : 'Rs ',
            ),
            validator: (v) {
              final p = _parsed;
              if (p == null) return percent ? 'Enter 0 – 100' : 'Enter an amount';
              if (p <= 0) return 'Must be more than zero';
              return null;
            },
          ),
          fieldGap,
          TextFormField(
            controller: _label,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Button label (optional)', hintText: 'e.g. Staff 20%, Student'),
            onFieldSubmitted: (_) => _done(),
          ),
        ]),
      ),
    );
  }
}
