import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/announcement.dart';
import 'security_service.dart';
import 'billing_service.dart';

class AnnouncementService {
  AnnouncementService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Announcement>> streamAnnouncements(String churchId, {int limit = 50}) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('announcements')
        .where('status', isEqualTo: PublishStatus.published.name)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Announcement.fromDoc(d.id, d.data())).toList());
  }

  // Admin stream (includes drafts)
  Stream<List<Announcement>> streamAllForAdmin(String churchId, {int limit = 100}) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('announcements')
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Announcement.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addAnnouncement(String churchId, Announcement a) async {
    await ZipModeService().guardWrite(churchId);
    // Quota check
    final billing = await BillingService().fetch(churchId);
    if (BillingService().isOverQuota(billing, resource: 'announcements') && (billing.graceUntil == null || billing.graceUntil!.isBefore(DateTime.now()))) {
      throw Exception('Announcement quota exceeded for current plan. Upgrade to add more announcements.');
    }
    await _firestore.collection('churches').doc(churchId).collection('announcements').add(a.toMap());
  }

  Future<void> updateStatus(String churchId, String id, PublishStatus status) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('announcements').doc(id).update({'status': status.name});
  }
}