import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/money.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

class ChargesSection extends ConsumerStatefulWidget {
  const ChargesSection({super.key});
  @override
  ConsumerState<ChargesSection> createState() => _ChargesSectionState();
}

class _ChargesSectionState extends SettingsFormState<ChargesSection> {
  late final _servicePct = ctrl();
  late final _deliveryRs = ctrl();
  late final _fbrRs = ctrl();
  bool _serviceOn = false, _serviceDineIn = true, _serviceTaxable = true;
  bool _deliveryOn = true, _deliveryTaxable = false;
  bool _fbrOn = true;

  ChargeSettings get _saved => ref.read(settingsValueProvider).charges;

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  Map<String, dynamic> get _draftMap => {
        'serviceEnabled': _serviceOn,
        'serviceBp': parseBp(_servicePct.text),
        'serviceDineInOnly': _serviceDineIn,
        'serviceTaxable': _serviceTaxable,
        'deliveryEnabled': _deliveryOn,
        'deliveryAmount': parseRupees(_deliveryRs.text),
        'deliveryTaxable': _deliveryTaxable,
        'fbrFeeEnabled': _fbrOn,
        'fbrFeeAmount': parseRupees(_fbrRs.text),
      };

  @override
  Object? draftJson() => _draftMap;

  @override
  void load() {
    final s = _saved;
    _serviceOn = s.serviceEnabled;
    _serviceDineIn = s.serviceDineInOnly;
    _serviceTaxable = s.serviceTaxable;
    _deliveryOn = s.deliveryEnabled;
    _deliveryTaxable = s.deliveryTaxable;
    _fbrOn = s.fbrFeeEnabled;
    setText(_servicePct, bpText(s.serviceBp));
    setText(_deliveryRs, rupeeText(s.deliveryAmount));
    setText(_fbrRs, rupeeText(s.fbrFeeAmount));
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.charges, ChargeSettings.fromJson(_draftMap).toJson());

  @override
  String get savedMessage => 'Charges saved';

  @override
  Widget build(BuildContext context) {
    final fbrIntegrationOn = ref.watch(settingsValueProvider).fbr.enabled;
    return SettingsScaffold(
      title: 'Charges & fees',
      subtitle: 'Added to the bill automatically, depending on the order type.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Service charge',
          subtitle: 'A percentage of the items after discounts.',
          icon: Icons.room_service_outlined,
          children: [
            LabeledSwitch(title: 'Charge a service charge', value: _serviceOn, onChanged: (v) => setState(() => _serviceOn = v)),
            if (_serviceOn) ...[
              const SizedBox(height: Sp.sm),
              SizedBox(
                width: 220,
                child: TextFormField(
                  controller: _servicePct,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInput,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Service charge', suffixText: '%'),
                  validator: (v) => _serviceOn ? pctValidator(v) : null,
                ),
              ),
              const SizedBox(height: Sp.sm),
              LabeledSwitch(
                title: 'Dine-in only',
                subtitle: 'Don’t charge it on takeaway and delivery',
                value: _serviceDineIn,
                onChanged: (v) => setState(() => _serviceDineIn = v),
              ),
              LabeledSwitch(
                title: 'Taxable',
                subtitle: 'GST is charged on the service charge too',
                value: _serviceTaxable,
                onChanged: (v) => setState(() => _serviceTaxable = v),
              ),
            ],
          ],
        ),
        SettingsCard(
          title: 'Delivery charge',
          subtitle: 'A fixed amount added to delivery orders.',
          icon: Icons.delivery_dining_outlined,
          children: [
            LabeledSwitch(title: 'Charge for delivery', value: _deliveryOn, onChanged: (v) => setState(() => _deliveryOn = v)),
            if (_deliveryOn) ...[
              const SizedBox(height: Sp.sm),
              SizedBox(
                width: 220,
                child: TextFormField(
                  controller: _deliveryRs,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInput,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Delivery charge', prefixText: 'Rs '),
                  validator: (v) => _deliveryOn ? rupeeValidator(v) : null,
                ),
              ),
              const SizedBox(height: Sp.sm),
              LabeledSwitch(
                title: 'Taxable',
                subtitle: 'GST is charged on the delivery charge too',
                value: _deliveryTaxable,
                onChanged: (v) => setState(() => _deliveryTaxable = v),
              ),
            ],
          ],
        ),
        SettingsCard(
          title: 'FBR POS fee',
          subtitle: 'The fixed fee FBR requires on every invoice from an integrated POS. Never taxed.',
          icon: Icons.verified_outlined,
          children: [
            LabeledSwitch(title: 'Charge the FBR POS fee', value: _fbrOn, onChanged: (v) => setState(() => _fbrOn = v)),
            if (_fbrOn) ...[
              const SizedBox(height: Sp.sm),
              SizedBox(
                width: 220,
                child: TextFormField(
                  controller: _fbrRs,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInput,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Fee per invoice', prefixText: 'Rs ', helperText: 'Usually Rs 1'),
                  validator: (v) => _fbrOn ? rupeeValidator(v) : null,
                  onFieldSubmitted: (_) => save(),
                ),
              ),
            ],
            if (!fbrIntegrationOn) ...[
              const SizedBox(height: Sp.md),
              const InfoBanner(
                'FBR integration is turned off, so the fee is not charged right now. Turn it on in FBR integration.',
                tone: Tone.warning,
                icon: Icons.info_outline_rounded,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
