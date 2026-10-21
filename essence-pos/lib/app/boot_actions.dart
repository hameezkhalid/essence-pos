import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-level actions that tear down and rebuild the running terminal.
abstract class BootActions {
  /// Signs this terminal out of the store account. Refuses while changes are waiting to upload.
  Future<String?> signOut();

  /// Deletes sales history (orders, refunds, shifts, cash, audit) keeping menu, staff, settings
  /// and current stock levels. Invoice numbers keep counting up.
  Future<String?> clearSalesHistory(void Function(String step) onStep);

  /// Changes this terminal's display name and invoice code.
  Future<void> renameTerminal(String name, String code);

  /// Signed-in store account email (for display).
  String? get accountEmail;
}

final bootActionsProvider = Provider<BootActions>((ref) => throw UnimplementedError('bootActionsProvider not overridden'));
