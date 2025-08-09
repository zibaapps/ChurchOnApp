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

  // Tithes
  CollectionReference<Map<String, dynamic>> _titheCol(String churchId) => _firestore.collection('churches').doc(churchId).collection('tithes');

  Stream<List<TitheRecord>> streamMyTithes(String churchId, String userId) {
    return _titheCol(churchId)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TitheRecord.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addOrEditTithe(String churchId, TitheRecord t) async {
    await _titheCol(churchId).doc(t.id).set(t.toMap(), SetOptions(merge: true));
  }
}