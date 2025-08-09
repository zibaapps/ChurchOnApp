import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsService {
  ContactsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) => _firestore.collection('users').doc(uid).collection('emergency_contacts');

  Stream<List<Map<String, dynamic>>> streamContacts(String uid) {
    return _col(uid).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> addContact(String uid, {required String name, required String number}) async {
    await _col(uid).add({'name': name, 'number': number, 'createdAt': DateTime.now().toUtc().toIso8601String()});
  }

  Future<void> deleteContact(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }
}