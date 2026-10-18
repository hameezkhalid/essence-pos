import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

String hourLabel(int h) => h == 0 ? '12 AM (midnight)' : '$h AM';

class StoreSection extends ConsumerStatefulWidget {
  const StoreSection({super.key});
  @override
  ConsumerState<StoreSection> createState() => _StoreSectionState();
}

class _StoreSectionState extends SettingsFormState<StoreSection> {
  late final _name = ctrl();
  late final _tagline = ctrl();
  late final _address = ctrl();
  late final _phone = ctrl();
  late final _email = ctrl();
  late final _ntn = ctrl();
  late final _strn = ctrl();
  late final _owner = ctrl();
  late final _prefix = ctrl();
  int _dayStart = 4;

  StoreSettings get _saved => ref.read(settingsValueProvider).store;

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  StoreSettings get _draft => _saved.copyWith(
        name: _name.text.trim(),
        tagline: _tagline.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        ntn: _ntn.text.trim(),
        strn: _strn.text.trim(),
        ownerCompany: _owner.text.trim(),
        invoicePrefix: _prefix.text.trim().toUpperCase(),
        dayStartHour: _dayStart,
      );

  @override
  Object? draftJson() => _draft.toJson();

  @override
  void load() {
    final s = _saved;
    setText(_name, s.name);
    setText(_tagline, s.tagline);
    setText(_address, s.address);
    setText(_phone, s.phone);
    setText(_email, s.email);
    setText(_ntn, s.ntn);
    setText(_strn, s.strn);
    setText(_owner, s.ownerCompany);
    setText(_prefix, s.invoicePrefix);
    _dayStart = s.dayStartHour.clamp(0, 6);
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.store, _draft.toJson());

  @override
  String get savedMessage => 'Store profile saved';

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(servicesProvider).device.code;
    final prefix = _prefix.text.trim().isEmpty ? 'ESS' : _prefix.text.trim().toUpperCase();
    final prefixChanged = prefix != ref.watch(settingsValueProvider).store.invoicePrefix;
    return SettingsScaffold(
      title: 'Store profile',
      subtitle: 'How the café appears on receipts, invoices and the owner dashboard.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Business',
          icon: Icons.storefront_outlined,
          children: [
            FieldRow(children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Store name'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the store name' : null,
              ),
              TextFormField(
                controller: _tagline,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Tagline', hintText: 'Patisserie · Coffee · Moments'),
              ),
            ]),
            fieldGap,
            TextFormField(
              controller: _owner,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Owner company (billing entity)',
                hintText: 'Mix & Match Collection',
                helperText: 'The registered business that issues the invoices.',
              ),
            ),
          ],
        ),
        SettingsCard(
          title: 'Contact',
          icon: Icons.call_outlined,
          children: [
            TextFormField(
              controller: _address,
              textInputAction: TextInputAction.next,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Address', hintText: 'e.g. F-7 Markaz, Islamabad'),
            ),
            fieldGap,
            FieldRow(children: [
              TextFormField(
                controller: _phone,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]'))],
                decoration: const InputDecoration(labelText: 'Phone', hintText: '0300 1234567'),
              ),
              TextFormField(
                controller: _email,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : 'Enter a valid email';
                },
              ),
            ]),
          ],
        ),
        SettingsCard(
          title: 'Tax registration',
          subtitle: 'Printed on every sales tax invoice.',
          icon: Icons.badge_outlined,
          children: [
            FieldRow(children: [
              TextFormField(
                controller: _ntn,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'NTN', hintText: 'National Tax Number'),
              ),
              TextFormField(
                controller: _strn,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'STRN', hintText: 'Sales Tax Registration No.'),
              ),
            ]),
          ],
        ),
        SettingsCard(
          title: 'Invoices & business day',
          icon: Icons.event_note_outlined,
          children: [
            FieldRow(children: [
              TextFormField(
                controller: _prefix,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(6),
                  TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toUpperCase())),
                ],
                decoration: InputDecoration(labelText: 'Invoice prefix', helperText: 'Invoices look like $prefix-$code-000123'),
                validator: (v) => (v ?? '').trim().length < 2 ? '2 – 6 letters or digits' : null,
                onFieldSubmitted: (_) => save(),
              ),
              DropdownButtonFormField<int>(
                key: ValueKey('day$loadGen'),
                initialValue: _dayStart,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Business day starts at'),
                items: [for (var h = 0; h <= 6; h++) DropdownMenuItem(value: h, child: Text(hourLabel(h)))],
                onChanged: (v) => setState(() => _dayStart = v ?? _dayStart),
              ),
            ]),
            const SizedBox(height: Sp.md),
            InfoBanner(
              'Sales made after midnight but before ${hourLabel(_dayStart).replaceAll(' (midnight)', '')} count towards the previous day, '
              'so late-night sales stay on the same day’s reports and Z-report.',
              icon: Icons.nights_stay_outlined,
            ),
            if (prefixChanged) ...[
              const SizedBox(height: Sp.sm),
              const InfoBanner(
                'Changing the prefix only affects new invoices. Existing invoices keep their numbers.',
                tone: Tone.warning,
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
