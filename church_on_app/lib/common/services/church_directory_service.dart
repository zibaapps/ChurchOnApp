import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/church_info.dart';

class ChurchDirectoryService {
  ChurchDirectoryService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<List<ChurchInfo>> streamChurches({int limit = 100}) {
    return _firestore
        .collection('churches')
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => ChurchInfo.fromDoc(d.id, d.data())).toList());
  }
}