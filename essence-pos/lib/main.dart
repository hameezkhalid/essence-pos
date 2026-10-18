import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/boot.dart';
import 'dashboard/dashboard_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The web build is the owner's live dashboard (Firebase Hosting); desktop/Android run the till.
  runApp(kIsWeb ? const DashboardApp() : const BootApp());
}
