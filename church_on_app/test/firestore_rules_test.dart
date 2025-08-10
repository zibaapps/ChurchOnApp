import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:church_on_app/firebase_options.dart';

Future<bool> _init() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // ignore if already initialized
  }
  try {
    // If emulator host is provided in env, point Firestore there
    final host = const String.fromEnvironment('FIRESTORE_EMULATOR_HOST');
    if (host.isNotEmpty) {
      final parts = host.split(':');
      FirebaseFirestore.instance.useFirestoreEmulator(parts.first, int.parse(parts.last));
    }
    // Touch instance to ensure ready
    // ignore: unnecessary_statements
    FirebaseFirestore.instance;
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firestore rules', () {
    late bool ready;
    setUpAll(() async {
      ready = await _init();
    });

    test('public sermons readable', () async {
      if (!ready) {
        return; // skip when emulator/Firebase not available
      }
      final fs = FirebaseFirestore.instance;
      final q = await fs.collection('churches').doc('test').collection('sermons').limit(1).get();
      expect(q.docs, isA<List<QueryDocumentSnapshot>>());
    });
  });
}