import 'dart:convert';

import 'package:http/http.dart' as http;

class AccountException implements Exception {
  AccountException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Creates store logins for admins. It calls Firebase Auth's REST API directly so the admin's
/// own session on this till is not replaced by the new account (the SDK's createUser signs in as it).
class AccountAdmin {
  AccountAdmin(this.apiKey, {http.Client? client}) : _client = client ?? http.Client();
  final String apiKey;
  final http.Client _client;

  Future<Map<String, dynamic>> _post(String method, Map<String, dynamic> body) async {
    final r = await _client
        .post(
          Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$method?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode != 200) {
      final code = ((data['error'] as Map?)?['message'] as String?) ?? 'UNKNOWN';
      throw AccountException(switch (code.split(' ').first) {
        'EMAIL_EXISTS' => 'That email already has a login. Use another email, or ask its owner to share it.',
        'INVALID_EMAIL' => 'That email address doesn’t look right.',
        'WEAK_PASSWORD' => 'Use at least 6 characters for the password.',
        'EMAIL_NOT_FOUND' => 'There is no login with that email.',
        'TOO_MANY_ATTEMPTS_TRY_LATER' => 'Too many attempts. Try again in a few minutes.',
        'OPERATION_NOT_ALLOWED' => 'Email logins are turned off in Firebase Authentication.',
        _ => 'Firebase: $code',
      });
    }
    return data;
  }

  /// Creates a login and returns its uid.
  Future<String> createLogin({required String email, required String password}) async {
    final d = await _post('signUp', {'email': email.trim(), 'password': password, 'returnSecureToken': false});
    return d['localId'] as String;
  }

  /// Emails a password-reset link to [email].
  Future<void> sendPasswordReset(String email) => _post('sendOobCode', {'requestType': 'PASSWORD_RESET', 'email': email.trim()});
}
