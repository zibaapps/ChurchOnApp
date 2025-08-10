import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_issue.dart';
import 'security_service.dart';

class ServiceIssueService {
  ServiceIssueService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String churchId) => _firestore.collection('churches').doc(churchId).collection('service_issues');

  Stream<List<ServiceIssue>> streamIssues(String churchId, {IssueStatus? status}) {
    Query<Map<String, dynamic>> q = _col(churchId).orderBy('createdAt', descending: true);
    if (status != null) q = q.where('status', isEqualTo: status.name);
    return q.snapshots().map((s) => s.docs.map((d) => ServiceIssue.fromDoc(d.id, d.data())).toList());
  }

  Future<void> createIssue(String churchId, ServiceIssue issue) async {
    await ZipModeService().guardWrite(churchId);
    await _col(churchId).add(issue.toMap());
  }

  Future<void> updateStatus(String churchId, String issueId, IssueStatus status, {required String updatedBy}) async {
    await ZipModeService().guardWrite(churchId);
    final ref = _col(churchId).doc(issueId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final prev = (snap.data() as Map<String, dynamic>?)?['status'] as String? ?? 'open';
      txn.update(ref, {'status': status.name});
      txn.set(ref.collection('audit').doc(), {
        'ts': DateTime.now().toUtc().toIso8601String(),
        'updatedBy': updatedBy,
        'from': prev,
        'to': status.name,
      });
    });
  }
}