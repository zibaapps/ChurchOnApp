import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/testimony.dart';

class TestimonyService {
  TestimonyService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String churchId) => _firestore.collection('churches').doc(churchId).collection('testimonies');

  Stream<List<Testimony>> streamApproved(String churchId) {
    return _col(churchId).where('status', isEqualTo: TestimonyStatus.approved.name).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => Testimony.fromDoc(d.id, d.data())).toList());
  }

  Future<void> submit(String churchId, Testimony t) async {
    await _col(churchId).add(t.toMap());
  }

  Future<void> like(String churchId, String id) async {
    await _col(churchId).doc(id).update({'likes': FieldValue.increment(1)});
  }
}