import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/platform.dart';
import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/services/web_order_intake.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

/// This till's "receive website orders" switch (device-local, on unless turned off).
final receiveOnlineProvider = StreamProvider<bool>((ref) => ref.watch(dbProvider).watchMeta(kReceiveOnlineMeta).map((v) => v != 'false'));

class OnlineSection extends ConsumerStatefulWidget {
  const OnlineSection({super.key});
  @override
  ConsumerState<OnlineSection> createState() => _OnlineSectionState();
}

class _OnlineSectionState extends SettingsFormState<OnlineSection> {
  late final _whatsapp = ctrl();
  late final _hours = ctrl();
  late final _placed = ctrl();
  late final _ready = ctrl();
  late final _cancelled = ctrl();
  bool _accepting = false;
  bool _sendToBar = false;

  OnlineOrderSettings get _saved => ref.read(settingsValueProvider).online;
  OnlineOrderSettings get _draft => OnlineOrderSettings(
        accepting: _accepting,
        whatsapp: _whatsapp.text.trim(),
        hours: _hours.text.trim(),
        sendToBar: _sendToBar,
        placedTemplate: _placed.text.trim(),
        readyTemplate: _ready.text.trim(),
        cancelledTemplate: _cancelled.text.trim(),
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
    _accepting = s.accepting;
    _sendToBar = s.sendToBar;
    setText(_whatsapp, s.whatsapp);
    setText(_hours, s.hours);
    setText(_placed, s.placedTemplate);
    setText(_ready, s.readyTemplate);
    setText(_cancelled, s.cancelledTemplate);
  }

  @override
  String? validate() {
    final n = waNumber(_whatsapp.text);
    if (_whatsapp.text.trim().isNotEmpty && !RegExp(r'^923\d{9}$').hasMatch(n)) return 'Enter the WhatsApp number as 03XX XXXXXXX';
    if (_accepting && _whatsapp.text.trim().isEmpty) return 'Add the shop WhatsApp number before taking online orders';
    return null;
  }

  @override
  Future<void> persist() async {
    final svc = ref.read(servicesProvider);
    await svc.settingsRepo.save(SettingKeys.online, _draft.toJson());
    unawaited(svc.publishWebsiteInfo(online: _draft));
  }

  @override
  String get savedMessage => 'Online orders saved';

  Widget _template(String label, TextEditingController c, String fallback) => TextFormField(
        controller: c,
        minLines: 2,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            tooltip: 'Reset to default',
            onPressed: () => c.text = fallback,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ),
        validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a message' : null,
      );

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(servicesProvider);
    final receiving = ref.watch(receiveOnlineProvider).value ?? true;
    final cloud = svc.webInbox != null;
    return SettingsScaffold(
      title: 'Online orders',
      subtitle: 'Pickup orders from the Essence website arrive as held orders tagged WEB, with a chime.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        if (!cloud)
          const InfoBanner('Online orders need this terminal to be connected to the store’s cloud account.', tone: Tone.warning),
        SettingsCard(
          title: 'Website ordering',
          icon: Icons.language_rounded,
          children: [
            LabeledSwitch(
              title: 'Take pickup orders on the website',
              subtitle: _accepting
                  ? 'On. Customers can place pickup orders. If no till is receiving orders for 15 minutes, the website pauses ordering on its own.'
                  : 'Off. The website shows the menu, but ordering is paused.',
              value: _accepting,
              onChanged: (v) => setState(() => _accepting = v),
            ),
            LabeledSwitch(
              title: 'Send online orders to the bar',
              subtitle: 'Print a bar ticket as soon as an order arrives.',
              value: _sendToBar,
              onChanged: (v) => setState(() => _sendToBar = v),
            ),
          ],
        ),
        SettingsCard(
          title: 'Shown on the website',
          subtitle: 'The address comes from Store profile.',
          icon: Icons.storefront_outlined,
          children: [
            FieldRow(children: [
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
                decoration: const InputDecoration(labelText: 'Shop WhatsApp number', hintText: '0300 1234567'),
              ),
              TextFormField(
                controller: _hours,
                decoration: const InputDecoration(labelText: 'Opening hours', hintText: 'Daily 12 pm – 12 am'),
              ),
            ]),
          ],
        ),
        SettingsCard(
          title: 'WhatsApp messages',
          subtitle: 'Sent from Held orders with one tap. Fill-ins: ${OnlineOrderSettings.placeholders}',
          icon: Icons.chat_outlined,
          children: [
            _template('Order placed', _placed, OnlineOrderSettings.defaultPlaced),
            fieldGap,
            _template('Ready for pickup', _ready, OnlineOrderSettings.defaultReady),
            fieldGap,
            _template('Cancelled', _cancelled, OnlineOrderSettings.defaultCancelled),
          ],
        ),
        if (!adminPanel && cloud)
          SettingsCard(
            title: 'This terminal',
            icon: Icons.point_of_sale_outlined,
            trailing: Pill(receiving ? 'Receiving' : 'Not receiving', tone: receiving ? Tone.success : Tone.neutral, dense: true),
            children: [
              LabeledSwitch(
                title: 'Receive online orders on this till',
                subtitle: 'Only one till takes each order, so it is safe to leave this on everywhere.',
                value: receiving,
                onChanged: (v) => svc.db.setMeta(kReceiveOnlineMeta, '$v'),
              ),
              const SizedBox(height: Sp.xs),
            ],
          ),
      ],
    );
  }
}
