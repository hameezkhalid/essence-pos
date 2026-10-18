import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/order_models.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

IconData orderTypeIcon(OrderType t) => switch (t) {
      OrderType.dineIn => Icons.table_restaurant_outlined,
      OrderType.takeaway => Icons.shopping_bag_outlined,
      OrderType.delivery => Icons.delivery_dining_outlined,
    };

final _numbered = RegExp(r'^(.*?)(\d+)$');

/// Next [count] table labels for [area]: continues the area's naming (e.g. "T4" → "T5")
/// and never reuses a number already taken anywhere in the store.
List<String> nextTableLabels(List<DiningTable> all, List<DiningTable> inArea, int count) {
  var prefix = '';
  for (final t in inArea.reversed) {
    final m = _numbered.firstMatch(t.label.trim());
    if (m != null) {
      prefix = m.group(1)!;
      break;
    }
  }
  var n = 0;
  final taken = <String>{for (final t in all) t.label.trim().toLowerCase()};
  for (final t in all) {
    final m = _numbered.firstMatch(t.label.trim());
    if (m != null && m.group(1)!.toLowerCase() == prefix.toLowerCase()) {
      final v = int.parse(m.group(2)!);
      if (v > n) n = v;
    }
  }
  final out = <String>[];
  while (out.length < count) {
    n++;
    final l = '$prefix$n';
    if (!taken.contains(l.toLowerCase())) out.add(l);
  }
  return out;
}

class OrdersSection extends ConsumerStatefulWidget {
  const OrdersSection({super.key});
  @override
  ConsumerState<OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends SettingsFormState<OrdersSection> {
  bool _dineIn = true, _takeaway = true, _delivery = true, _reqTable = true, _reqPhone = true;
  OrderType _default = OrderType.takeaway;

  OrderTypeSettings get _saved => ref.read(settingsValueProvider).orderTypes;

  OrderTypeSettings get _draft => OrderTypeSettings(
        dineIn: _dineIn,
        takeaway: _takeaway,
        delivery: _delivery,
        defaultType: _default,
        requireTableForDineIn: _reqTable,
        requirePhoneForDelivery: _reqPhone,
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
    _dineIn = s.dineIn;
    _takeaway = s.takeaway;
    _delivery = s.delivery;
    _default = s.effectiveDefault;
    _reqTable = s.requireTableForDineIn;
    _reqPhone = s.requirePhoneForDelivery;
    if (!_dineIn && !_takeaway && !_delivery) _takeaway = true;
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.orderTypes, _draft.toJson());

  @override
  String get savedMessage => 'Order types saved';

  bool _on(OrderType t) => switch (t) { OrderType.dineIn => _dineIn, OrderType.takeaway => _takeaway, OrderType.delivery => _delivery };

  void _toggle(OrderType t, bool v) {
    final count = OrderType.values.where(_on).length;
    if (!v && count <= 1) {
      toast(context, 'At least one order type must stay on', error: true);
      return;
    }
    setState(() {
      switch (t) {
        case OrderType.dineIn:
          _dineIn = v;
        case OrderType.takeaway:
          _takeaway = v;
        case OrderType.delivery:
          _delivery = v;
      }
      if (!_on(_default)) _default = OrderType.values.firstWhere(_on);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = OrderType.values.where(_on).toList();
    return SettingsScaffold(
      title: 'Order types & tables',
      subtitle: 'Which kinds of orders the till takes, and the floor plan for dine-in.',
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Order types',
          icon: Icons.receipt_outlined,
          children: [
            for (final t in OrderType.values)
              Row(children: [
                Icon(orderTypeIcon(t), size: 20, color: _on(t) ? context.ec.accent : context.ec.textFaint),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: LabeledSwitch(
                    title: t.label,
                    subtitle: switch (t) {
                      OrderType.dineIn => 'Eat in, optionally at a table',
                      OrderType.takeaway => 'Collected at the counter',
                      OrderType.delivery => 'Delivered to the customer’s address',
                    },
                    value: _on(t),
                    onChanged: (v) => _toggle(t, v),
                  ),
                ),
              ]),
            const Divider(height: Sp.xl),
            Text('Default for new orders', style: context.tt.titleSmall),
            const SizedBox(height: Sp.sm),
            Segments<OrderType>(
              values: enabled,
              selected: _default,
              minWidth: enabled.length * 130,
              icon: orderTypeIcon,
              label: (t) => t.label,
              onChanged: (t) => setState(() => _default = t),
            ),
            const Divider(height: Sp.xl),
            LabeledSwitch(
              title: 'Require a table for dine-in',
              subtitle: 'Cashiers must pick a table before charging a dine-in order',
              value: _reqTable,
              onChanged: _dineIn ? (v) => setState(() => _reqTable = v) : null,
            ),
            LabeledSwitch(
              title: 'Require a phone number for delivery',
              subtitle: 'So the rider can call the customer',
              value: _reqPhone,
              onChanged: _delivery ? (v) => setState(() => _reqPhone = v) : null,
            ),
          ],
        ),
        const _FloorPlan(),
      ],
    );
  }
}

// ───────────────────────── Areas & tables ─────────────────────────

class _FloorPlan extends ConsumerWidget {
  const _FloorPlan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasProvider).value ?? const <Area>[];
    final tables = ref.watch(tablesProvider).value ?? const <DiningTable>[];
    final seats = tables.where((t) => t.active).fold<int>(0, (a, t) => a + t.seats);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(
        'Areas & tables',
        subtitle: tables.isEmpty ? 'Group tables by floor or area.' : '${areas.length} areas · ${tables.length} tables · $seats seats',
        trailing: OutlinedButton.icon(
          onPressed: () => _editArea(context, ref, null, areas),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add area'),
        ),
      ),
      if (areas.isEmpty)
        AppCard(
          child: EmptyState(
            icon: Icons.table_restaurant_outlined,
            title: 'No areas yet',
            message: 'Add an area such as “Ground floor” or “Terrace”, then add its tables.',
            action: FilledButton.icon(
              onPressed: () => _editArea(context, ref, null, areas),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add area'),
            ),
          ),
        )
      else
        for (var i = 0; i < areas.length; i++) ...[
          if (i > 0) const SizedBox(height: Sp.md),
          _AreaCard(area: areas[i], areas: areas, tables: tables),
        ],
    ]);
  }
}

Future<void> _editArea(BuildContext context, WidgetRef ref, Area? area, List<Area> areas) async {
  final name = await showAdaptive<String>(context, maxWidth: 440, builder: (_) => _NameDialog(title: area == null ? 'Add area' : 'Rename area', initial: area?.name ?? ''));
  if (name == null || name.trim().isEmpty) return;
  final repo = ref.read(servicesProvider).settingsRepo;
  if (area == null) {
    await repo.saveArea(Area(
      id: newId(),
      updatedAt: nowMs(),
      deleted: false,
      name: name.trim(),
      sortOrder: areas.fold(0, (a, x) => x.sortOrder >= a ? x.sortOrder + 1 : a),
    ));
    if (context.mounted) toast(context, '${name.trim()} added');
  } else {
    await repo.saveArea(area.copyWith(name: name.trim()));
  }
}

class _AreaCard extends ConsumerWidget {
  const _AreaCard({required this.area, required this.areas, required this.tables});
  final Area area;
  final List<Area> areas;
  final List<DiningTable> tables;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final repo = ref.read(servicesProvider).settingsRepo;
    final mine = tables.where((t) => t.areaId == area.id).toList();
    final seats = mine.where((t) => t.active).fold<int>(0, (a, t) => a + t.seats);

    Future<void> addTables(int count) async {
      final labels = nextTableLabels(tables, mine, count);
      var sort = mine.fold<int>(0, (a, t) => t.sortOrder >= a ? t.sortOrder + 1 : a);
      final seatsDefault = mine.isEmpty ? 4 : mine.last.seats;
      for (final l in labels) {
        await repo.saveTable(DiningTable(
          id: newId(),
          updatedAt: nowMs(),
          deleted: false,
          areaId: area.id,
          label: l,
          seats: seatsDefault,
          sortOrder: sort++,
          active: true,
        ));
      }
      if (context.mounted) toast(context, count == 1 ? 'Table ${labels.first} added' : 'Tables ${labels.first} – ${labels.last} added');
    }

    Future<void> deleteArea() async {
      final ok = await confirm(
        context,
        title: 'Delete ${area.name}?',
        message: mine.isEmpty ? 'This area has no tables.' : 'Its ${mine.length} tables will be deleted too. Past orders keep their table labels.',
        confirmLabel: 'Delete',
        destructive: true,
      );
      if (!ok) return;
      for (final t in mine) {
        await repo.deleteTable(t);
      }
      await repo.deleteArea(area);
      if (context.mounted) toast(context, '${area.name} deleted');
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.sm, Sp.lg),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(Icons.layers_outlined, size: 20, color: ec.accent),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(area.name, style: context.tt.titleMedium, overflow: TextOverflow.ellipsis),
              Text('${mine.length} table${mine.length == 1 ? '' : 's'} · $seats seats', style: context.tt.bodySmall),
            ]),
          ),
          PopupMenuButton<String>(
            tooltip: 'More for ${area.name}',
            onSelected: (v) {
              if (v == 'rename') _editArea(context, ref, area, areas);
              if (v == 'delete') deleteArea();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'rename', child: ListTile(leading: Icon(Icons.drive_file_rename_outline_rounded), title: Text('Rename'))),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: ec.danger), title: Text('Delete area', style: TextStyle(color: ec.danger))),
              ),
            ],
          ),
        ]),
        const SizedBox(height: Sp.md),
        Padding(
          padding: const EdgeInsets.only(right: Sp.sm),
          child: mine.isEmpty
              ? Text('No tables in this area yet.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted))
              : Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
                  for (final t in mine) _TableChip(table: t, onTap: () => _editTable(context, t)),
                ]),
        ),
        const SizedBox(height: Sp.md),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          OutlinedButton.icon(onPressed: () => _editTable(context, null), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add table')),
          TextButton.icon(onPressed: () => addTables(4), icon: const Icon(Icons.playlist_add_rounded, size: 18), label: const Text('Add 4 tables')),
        ]),
      ]),
    );
  }

  Future<void> _editTable(BuildContext context, DiningTable? t) => showAdaptive<void>(
        context,
        maxWidth: 460,
        builder: (_) => _TableDialog(table: t, area: area, areas: areas, tables: tables),
      );
}

class _TableChip extends StatelessWidget {
  const _TableChip({required this.table, required this.onTap});
  final DiningTable table;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final on = table.active;
    return Tooltip(
      message: on ? 'Edit table ${table.label}' : 'Table ${table.label} (hidden)',
      child: Material(
        color: on ? ec.beige : ec.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: ec.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.md),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 6),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(table.label, style: context.tt.titleSmall?.copyWith(color: on ? ec.text : ec.textFaint, decoration: on ? null : TextDecoration.lineThrough)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.chair_outlined, size: 12, color: ec.textMuted),
                  const SizedBox(width: 3),
                  Text('${table.seats}', style: context.tt.labelSmall),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableDialog extends ConsumerStatefulWidget {
  const _TableDialog({this.table, required this.area, required this.areas, required this.tables});
  final DiningTable? table;
  final Area area;
  final List<Area> areas;
  final List<DiningTable> tables;
  @override
  ConsumerState<_TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends ConsumerState<_TableDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _label;
  late int _seats;
  late String _areaId;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final t = widget.table;
    final inArea = widget.tables.where((x) => x.areaId == widget.area.id).toList();
    _label = TextEditingController(text: t?.label ?? nextTableLabels(widget.tables, inArea, 1).first);
    _seats = t?.seats ?? (inArea.isEmpty ? 4 : inArea.last.seats);
    _areaId = t?.areaId ?? widget.area.id;
    _active = t?.active ?? true;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final repo = ref.read(servicesProvider).settingsRepo;
    final t = widget.table;
    final label = _label.text.trim();
    if (t == null) {
      final inArea = widget.tables.where((x) => x.areaId == _areaId);
      await repo.saveTable(DiningTable(
        id: newId(),
        updatedAt: nowMs(),
        deleted: false,
        areaId: _areaId,
        label: label,
        seats: _seats,
        sortOrder: inArea.fold(0, (a, x) => x.sortOrder >= a ? x.sortOrder + 1 : a),
        active: _active,
      ));
    } else {
      await repo.saveTable(t.copyWith(label: label, seats: _seats, areaId: _areaId, active: _active));
    }
    if (!mounted) return;
    Navigator.pop(context);
    toast(context, t == null ? 'Table $label added' : 'Table $label saved');
  }

  Future<void> _delete() async {
    final t = widget.table!;
    final ok = await confirm(context, title: 'Delete table ${t.label}?', confirmLabel: 'Delete', destructive: true);
    if (!ok || !mounted) return;
    await ref.read(servicesProvider).settingsRepo.deleteTable(t);
    if (!mounted) return;
    Navigator.pop(context);
    toast(context, 'Table ${t.label} deleted');
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.table != null;
    return DialogFrame(
      title: editing ? 'Table ${widget.table!.label}' : 'Add table',
      subtitle: editing ? null : widget.area.name,
      icon: Icons.table_restaurant_outlined,
      actions: [
        if (editing)
          TextButton.icon(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: context.ec.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Delete'),
          ),
        ...dialogActions(context, saveLabel: editing ? 'Save' : 'Add table', onSave: _save),
      ],
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _label,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Table label', hintText: 'e.g. 5 or T5'),
            validator: (v) {
              final l = (v ?? '').trim();
              if (l.isEmpty) return 'Enter a label';
              if (l.length > 8) return 'Keep it short (max 8 characters)';
              final dup = widget.tables.any((x) => x.id != widget.table?.id && x.label.trim().toLowerCase() == l.toLowerCase());
              return dup ? 'Another table already uses this label' : null;
            },
            onFieldSubmitted: (_) => _save(),
          ),
          fieldGap,
          DropdownButtonFormField<String>(
            initialValue: _areaId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Area'),
            items: [for (final a in widget.areas) DropdownMenuItem(value: a.id, child: Text(a.name))],
            onChanged: (v) => setState(() => _areaId = v ?? _areaId),
          ),
          const SizedBox(height: Sp.lg),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Seats', style: context.tt.titleSmall),
                Text('Shown on the table picker', style: context.tt.bodySmall),
              ]),
            ),
            QtyStepper(value: _seats, min: 1, max: 30, onChanged: (v) => setState(() => _seats = v)),
          ]),
          const SizedBox(height: Sp.sm),
          LabeledSwitch(
            title: 'Available',
            subtitle: 'Turn off to hide the table from the picker',
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
        ]),
      ),
    );
  }
}

/// Asks for a single name.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.initial});
  final String title;
  final String initial;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _form = GlobalKey<FormState>();
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _done() {
    if (_form.currentState!.validate()) Navigator.pop(context, _c.text.trim());
  }

  @override
  Widget build(BuildContext context) => DialogFrame(
        title: widget.title,
        icon: Icons.layers_outlined,
        actions: dialogActions(context, saveLabel: 'Save', onSave: _done),
        child: Form(
          key: _form,
          child: TextFormField(
            controller: _c,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Area name', hintText: 'e.g. Ground floor, Terrace'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
            onFieldSubmitted: (_) => _done(),
          ),
        ),
      );
}
