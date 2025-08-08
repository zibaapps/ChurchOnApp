import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInit {
  static Future<void> enablePersistence() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.enablePersistence(const PersistenceSettings(synchronizeTabs: true));
  }
}