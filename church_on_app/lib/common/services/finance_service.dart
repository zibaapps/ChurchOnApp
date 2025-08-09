import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/finance.dart';

class FinanceService {
  FinanceService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  // Contribution pools
  CollectionReference<Map<String, dynamic>> _poolCol(String churchId) => _firestore.collection('churches').doc(churchId).collection('contribution_pools');

  Stream<List<ContributionPool>> streamPools(String churchId) {
    return _poolCol(churchId)
        .orderBy('title')
        .snapshots()
        .map((s) => s.docs.map((d) => ContributionPool.fromDoc(d.id, d.data())).toList());
  }

  Future<String> createPool(String churchId, ContributionPool pool) async {
    final ref = await _poolCol(churchId).add(pool.toMap());
    return ref.id;
  }

  Future<void> contribute(String churchId, String poolId, double amount) async {
    await _poolCol(churchId).doc(poolId).update({'currentAmount': FieldValue.increment(amount)});
  }

  Stream<List<Map<String, dynamic>>> streamContributors(String churchId, String poolId) {
    return _poolCol(churchId)
        .doc(poolId)
        .collection('contributors')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> addContributor(String churchId, String poolId, {required String userId, required double amount}) async {
    final ref = _poolCol(churchId).doc(poolId).collection('contributors').doc();
    await ref.set({
      'userId': userId,
      'amount': amount,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // Tithes
  CollectionReference<Map<String, dynamic>> _titheCol(String churchId) => _firestore.collection('churches').doc(churchId).collection('tithes');

  Stream<List<TitheRecord>> streamMyTithes(String churchId, String userId) {
    return _titheCol(churchId)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TitheRecord.fromDoc(d.id, d.data())).toList());
  }

  Stream<List<TitheRecord>> streamAllTithes(
    String churchId, {
    String? startIso, // ISO8601 strings for lexicographic queries
    String? endIso,
  }) {
    Query<Map<String, dynamic>> q = _titheCol(churchId).orderBy('createdAt', descending: true);
    if (startIso != null && startIso.isNotEmpty) {
      q = q.where('createdAt', isGreaterThanOrEqualTo: startIso);
    }
    if (endIso != null && endIso.isNotEmpty) {
      q = q.where('createdAt', isLessThanOrEqualTo: endIso);
    }
    return q.snapshots().map((s) => s.docs.map((d) => TitheRecord.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addOrEditTithe(String churchId, TitheRecord t) async {
    await _titheCol(churchId).doc(t.id).set(t.toMap(), SetOptions(merge: true));
  }
}