import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/news_item.dart';

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
    await _firestore.collection('churches').doc(churchId).collection('news').add(n.toMap());
  }

  Future<void> updateStatus(String churchId, String id, PublishStatus status) async {
    await _firestore.collection('churches').doc(churchId).collection('news').doc(id).update({'status': status.name});
  }
}