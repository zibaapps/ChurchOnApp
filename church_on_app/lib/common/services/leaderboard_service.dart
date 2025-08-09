import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  LeaderboardService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  static final Map<String, DateTime> _lastSubmitPerUserGame = <String, DateTime>{};

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
    bool shareNameGlobal = false,
  }) async {
    if (userId == 'guest') return;
    final key = '$userId/$game';
    final nowDt = DateTime.now();
    final last = _lastSubmitPerUserGame[key];
    if (last != null && nowDt.difference(last).inSeconds < 5) {
      return; // throttle
    }
    _lastSubmitPerUserGame[key] = nowDt;

    final safeScore = score.clamp(0, 100000); // sanity bound
    final now = nowDt.toUtc().toIso8601String();

    await _churchScores(churchId).add({
      'userId': userId,
      'userName': userName,
      'game': game,
      'score': safeScore,
      'createdAt': now,
      'optInGlobal': optInGlobal,
      'anonymous': false,
    });

    if (optInGlobal) {
      final publicName = shareNameGlobal ? (userName.isNotEmpty ? userName : 'User') : 'Anonymous';
      await _globalScores.add({
        'userId': userId,
        'userName': publicName,
        'anonymous': !shareNameGlobal,
        'churchId': churchId,
        'game': game,
        'score': safeScore,
        'createdAt': now,
      });
    }
  }

  String? _startIsoForTimeframe(String timeframe) {
    final now = DateTime.now().toUtc();
    if (timeframe == 'week') {
      final start = now.subtract(Duration(days: now.weekday - 1));
      return DateTime.utc(start.year, start.month, start.day).toIso8601String();
    } else if (timeframe == 'month') {
      final start = DateTime.utc(now.year, now.month, 1);
      return start.toIso8601String();
    }
    return null; // all-time
  }

  Stream<List<Map<String, dynamic>>> streamChurchTopAggregated(
    String churchId, {
    String game = 'all',
    String timeframe = 'all', // all | week | month
    int limit = 200,
  }) {
    Query<Map<String, dynamic>> q = _churchScores(churchId);
    final startIso = _startIsoForTimeframe(timeframe);
    if (startIso != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: startIso);
    }
    if (game != 'all') {
      q = q.where('game', isEqualTo: game);
    }
    q = q.orderBy('createdAt', descending: true).limit(limit);
    return q.snapshots().map((s) => _aggregateByUser(s.docs.map((d) => d.data()).toList()));
  }

  Stream<List<Map<String, dynamic>>> streamGlobalTopAggregated({
    String game = 'all',
    String timeframe = 'all',
    int limit = 400,
  }) {
    Query<Map<String, dynamic>> q = _globalScores;
    final startIso = _startIsoForTimeframe(timeframe);
    if (startIso != null) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: startIso);
    }
    if (game != 'all') {
      q = q.where('game', isEqualTo: game);
    }
    q = q.orderBy('createdAt', descending: true).limit(limit);
    return q
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