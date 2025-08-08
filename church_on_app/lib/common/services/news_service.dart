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
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => NewsItem.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addNews(String churchId, NewsItem n) async {
    await _firestore.collection('churches').doc(churchId).collection('news').add(n.toMap());
  }
}