import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  LeaderboardService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _churchScores(String churchId) =>
      _firestore.collection('churches').doc(churchId).collection('games_scores');
  CollectionReference<Map<String, dynamic>> get _globalScores => _firestore.collection('global_games_scores');

  Future<void> submitScore({
    required String churchId,
    required String userId,
    required String userName,
    required String game,
    required int score,
    required bool optInGlobal,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _churchScores(churchId).add({
      'userId': userId,
      'userName': userName,
      'game': game,
      'score': score,
      'createdAt': now,
      'optInGlobal': optInGlobal,
    });
    if (optInGlobal) {
      await _globalScores.add({
        'userId': userId,
        'userName': userName,
        'churchId': churchId,
        'game': game,
        'score': score,
        'createdAt': now,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> streamChurchTopAggregated(String churchId, {int limit = 100}) {
    return _churchScores(churchId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => _aggregateByUser(s.docs.map((d) => d.data()).toList()));
  }

  Stream<List<Map<String, dynamic>>> streamGlobalTopAggregated({int limit = 200}) {
    return _globalScores
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => _aggregateByUser(s.docs.map((d) => d.data()).toList()))
        .map((list) => list..sort((a, b) => (b['total'] as int).compareTo(a['total'] as int)));
  }

  List<Map<String, dynamic>> _aggregateByUser(List<Map<String, dynamic>> rows) {
    final Map<String, Map<String, dynamic>> acc = {};
    for (final r in rows) {
      final uid = r['userId'] as String? ?? '';
      final name = r['userName'] as String? ?? 'User';
      final score = (r['score'] as num?)?.toInt() ?? 0;
      final current = acc[uid];
      if (current == null) {
        acc[uid] = {'userId': uid, 'userName': name, 'total': score};
      } else {
        current['total'] = (current['total'] as int) + score;
      }
    }
    final list = acc.values.toList();
    list.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    return list;
  }
}