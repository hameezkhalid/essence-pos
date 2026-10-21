import 'package:flutter/foundation.dart';

/// The web build is the admin panel (dashboard, menu management and the same POS);
/// the Windows/macOS/Android builds are the till.
const bool adminPanel = kIsWeb;

/// Where the app opens after a staff member unlocks it.
const String homeRoute = adminPanel ? '/dashboard' : '/sell';
