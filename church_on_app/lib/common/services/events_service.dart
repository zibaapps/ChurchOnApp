import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

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

  Future<void> addEvent(String churchId, EventItem event) async {
    await _firestore.collection('churches').doc(churchId).collection('events').add(event.toMap());
  }

  Future<void> toggleRsvp(String churchId, String eventId, String uid, bool attend) async {
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