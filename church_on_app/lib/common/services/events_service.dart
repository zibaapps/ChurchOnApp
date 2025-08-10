import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import 'security_service.dart';
import '../models/page_result.dart';

class EventsService {
  EventsService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<EventItem>> streamUpcomingEvents(String churchId, {int limit = 50}) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('events')
        .where('endAt', isGreaterThanOrEqualTo: nowIso)
        .orderBy('endAt')
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => EventItem.fromDoc(d.id, d.data())).toList());
  }

  Future<PageResult<EventItem>> fetchUpcomingEventsPage(String churchId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    Query<Map<String, dynamic>> q = _firestore
        .collection('churches')
        .doc(churchId)
        .collection('events')
        .where('endAt', isGreaterThanOrEqualTo: nowIso)
        .orderBy('endAt')
        .limit(limit);
    if (startAfter != null) {
      q = (q as Query<Map<String, dynamic>>).startAfterDocument(startAfter);
    }
    final snap = await q.get();
    final items = snap.docs.map((d) => EventItem.fromDoc(d.id, d.data())).toList();
    final last = snap.docs.isEmpty ? null : snap.docs.last;
    final hasMore = snap.docs.length == limit;
    return PageResult<EventItem>(items: items, lastDoc: last, hasMore: hasMore);
  }

  Future<void> addEvent(String churchId, EventItem event) async {
    await ZipModeService().guardWrite(churchId);
    await _firestore.collection('churches').doc(churchId).collection('events').add(event.toMap());
  }

  Future<void> toggleRsvp(String churchId, String eventId, String uid, bool attend) async {
    await ZipModeService().guardWrite(churchId);
    final ref = _firestore.collection('churches').doc(churchId).collection('events').doc(eventId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
      final attendees = Map<String, dynamic>.from(data['attendees'] as Map? ?? {});
      if (attend) {
        attendees[uid] = true;
      } else {
        attendees.remove(uid);
      }
      txn.update(ref, {'attendees': attendees});
    });
  }
}