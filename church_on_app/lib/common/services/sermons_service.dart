import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sermon.dart';

class SermonsService {
  SermonsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Sermon>> streamSermons(String churchId, {int limit = 50}) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('sermons')
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Sermon.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addSermon(String churchId, Sermon sermon) async {
    await _firestore
        .collection('churches')
        .doc(churchId)
        .collection('sermons')
        .add(sermon.toMap());
  }
}