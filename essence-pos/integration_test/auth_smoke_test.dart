import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:essence_pos/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Signs in with the store admin and reads the store document (no writes).
/// Run: flutter test integration_test/auth_smoke_test.dart -d DEVICE \
///        --dart-define=ADMIN_EMAIL=... --dart-define=ADMIN_PASSWORD=...
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin can sign in and read the store', (tester) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: const String.fromEnvironment('ADMIN_EMAIL'), password: const String.fromEnvironment('ADMIN_PASSWORD'));
    expect(cred.user, isNotNull);
    final store = await FirebaseFirestore.instance.collection('stores').doc('essence').get(const GetOptions(source: Source.server));
    expect(store.exists, isTrue);
    expect((store.data()!['adminUids'] as List), contains(cred.user!.uid));
    await FirebaseAuth.instance.signOut();
  });
}
