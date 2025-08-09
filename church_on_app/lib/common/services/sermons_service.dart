import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sermon.dart';
import 'security_service.dart';
import '../models/page_result.dart';

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

  Future<String> addSermon(String churchId, Sermon sermon) async {
    await ZipModeService().guardWrite(churchId);
    final doc = await _firestore
        .collection('churches')
        .doc(churchId)
        .collection('sermons')
        .add(sermon.toMap());
    return doc.id;
  }

  Future<void> incrementView(String churchId, String sermonId) async {
    final ref = _firestore.collection('churches').doc(churchId).collection('sermons').doc(sermonId);
    await ref.update({'viewCount': FieldValue.increment(1)});
  }

  Future<PageResult<Sermon>> fetchSermonsPage(String churchId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    Query<Map<String, dynamic>> q = _firestore
        .collection('churches')
        .doc(churchId)
        .collection('sermons')
        .orderBy('publishedAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      q = (q as Query<Map<String, dynamic>>).startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final items = snap.docs.map((d) => Sermon.fromDoc(d.id, d.data())).toList();
    final last = snap.docs.isEmpty ? null : snap.docs.last;
    final hasMore = snap.docs.length == limit;
    return PageResult<Sermon>(items: items, lastDoc: last, hasMore: hasMore);
  }
}