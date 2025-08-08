import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report.dart';

class ReportsService {
  ReportsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<ChurchReport>> streamReports(String churchId, {ReportType? type, int limit = 50}) {
    Query<Map<String, dynamic>> q = _firestore
        .collection('churches')
        .doc(churchId)
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (type != null) {
      q = q.where('type', isEqualTo: type.name);
    }
    return q.snapshots().map((s) => s.docs.map((d) => ChurchReport.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addReport(String churchId, ChurchReport r) async {
    await _firestore.collection('churches').doc(churchId).collection('reports').add(r.toMap());
  }
}