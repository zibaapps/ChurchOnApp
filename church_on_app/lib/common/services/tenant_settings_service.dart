import 'package:cloud_firestore/cloud_firestore.dart';

class TenantSettingsService {
  TenantSettingsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<Map<String, dynamic>?> streamChurch(String churchId) {
    return _firestore.collection('churches').doc(churchId).snapshots().map((d) => d.data());
  }

  Future<void> updateChurch(String churchId, Map<String, dynamic> data) async {
    await _firestore.collection('churches').doc(churchId).set(data, SetOptions(merge: true));
  }
}