import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report.dart';
import 'security_service.dart';

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

  // Bishop can view pastor reports from child churches by specifying assignedLeaderChurchId on reports
  Stream<List<ChurchReport>> streamBishopScope(String leaderChurchId, {int limit = 100}) {
    final q = _firestore
        .collectionGroup('reports')
        .where('visibility', isEqualTo: ReportVisibility.bishop.name)
        .where('assignedLeaderChurchId', isEqualTo: leaderChurchId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    return q.snapshots().map((s) => s.docs.map((d) => ChurchReport.fromDoc(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  // Board leader over a church sees board-visible reports for that church
  Stream<List<ChurchReport>> streamBoardScope(String churchId, {int limit = 100}) {
    final q = _firestore
        .collection('churches')
        .doc(churchId)
        .collection('reports')
        .where('visibility', isEqualTo: ReportVisibility.board.name)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    return q.snapshots().map((s) => s.docs.map((d) => ChurchReport.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addReport(String churchId, ChurchReport r) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('reports').add(r.toMap());
  }

  Future<void> updateVisibility(String churchId, String reportId, ReportVisibility v) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('reports').doc(reportId).update({'visibility': v.name});
  }

  Future<void> assignLeader(String churchId, String reportId, String? leaderChurchId) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('reports').doc(reportId).update({'assignedLeaderChurchId': leaderChurchId});
  }
}