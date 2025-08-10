import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_item.dart';
import 'security_service.dart';
import '../models/page_result.dart';

class NewsService {
  NewsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<NewsItem>> streamNews(String churchId, {int limit = 50}) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('news')
        .where('status', isEqualTo: PublishStatus.published.name)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => NewsItem.fromDoc(d.id, d.data())).toList());
  }

  // Admin stream (includes drafts)
  Stream<List<NewsItem>> streamAllForAdmin(String churchId, {int limit = 100}) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => NewsItem.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addNews(String churchId, NewsItem n) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('news').add(n.toMap());
  }

  Future<String> addNewsReturnId(String churchId, NewsItem n) async {
    await ZipModeService().guardWrite(churchId);
    final doc = await _firestore.collection('churches').doc(churchId).collection('news').add(n.toMap());
    return doc.id;
  }

  Future<void> updateStatus(String churchId, String id, PublishStatus status) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('news').doc(id).update({'status': status.name});
  }

  Future<PageResult<NewsItem>> fetchNewsPage(String churchId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    Query<Map<String, dynamic>> q = _firestore
        .collection('churches')
        .doc(churchId)
        .collection('news')
        .where('status', isEqualTo: PublishStatus.published.name)
        .orderBy('publishedAt', descending: true)
        .limit(limit);
    if (startAfter != null) {
      q = (q as Query<Map<String, dynamic>>).startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final items = snap.docs.map((d) => NewsItem.fromDoc(d.id, d.data())).toList();
    final last = snap.docs.isEmpty ? null : snap.docs.last;
    final hasMore = snap.docs.length == limit;
    return PageResult<NewsItem>(items: items, lastDoc: last, hasMore: hasMore);
  }
}