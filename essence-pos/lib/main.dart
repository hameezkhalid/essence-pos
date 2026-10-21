import 'package:flutter/material.dart';

import 'app/boot.dart';

/// One app, two faces: the Windows build is the till (POS); the web build is the admin panel
/// (dashboard, menu and the same POS). See `adminPanel` in app/platform.dart.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootApp());
}
