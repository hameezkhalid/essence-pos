import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/services/web_order_intake.dart';

/// Opens WhatsApp with [text] ready to send to [phone] (the shop's own WhatsApp sends it).
/// Desktop tries the WhatsApp app first, then falls back to wa.me in the browser.
Future<bool> openWhatsApp(String phone, String text) async {
  final desktop = !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS);
  if (desktop) {
    final app = Uri.parse('whatsapp://send?phone=${waNumber(phone)}&text=${Uri.encodeComponent(text)}');
    try {
      if (await launchUrl(app, mode: LaunchMode.externalApplication)) return true;
    } catch (_) {}
  }
  try {
    return await launchUrl(whatsAppUri(phone, text), mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
