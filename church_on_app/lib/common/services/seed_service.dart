import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  SeedService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<void> seedTenant(String churchId) async {
    final batch = _firestore.batch();
    final churchRef = _firestore.collection('churches').doc(churchId);

    // Sample sermons
    for (int i = 1; i <= 5; i++) {
      final ref = churchRef.collection('sermons').doc();
      batch.set(ref, {
        'churchId': churchId,
        'title': 'Hope Series Part $i',
        'mediaType': 'video',
        'mediaUrl': 'https://example.com/video$i.mp4',
        'publishedAt': DateTime.now().toUtc().toIso8601String(),
        'isFeatured': i == 1,
        'viewCount': 0,
      });
    }

    // Sample events
    for (int i = 1; i <= 5; i++) {
      final ref = churchRef.collection('events').doc();
      final start = DateTime.now().add(Duration(days: i));
      final end = start.add(const Duration(hours: 2));
      batch.set(ref, {
        'churchId': churchId,
        'name': 'Worship Night $i',
        'startAt': start.toUtc().toIso8601String(),
        'endAt': end.toUtc().toIso8601String(),
        'location': 'Main Auditorium',
        'allowRsvp': true,
        'attendees': {},
      });
    }

    // Sample news
    for (int i = 1; i <= 5; i++) {
      final ref = churchRef.collection('news').doc();
      batch.set(ref, {
        'churchId': churchId,
        'headline': 'Church Update $i',
        'body': 'This is a sample church news item number $i.',
        'publishedAt': DateTime.now().toUtc().toIso8601String(),
        'status': 'published',
      });
    }

    // Sample announcements
    for (int i = 1; i <= 3; i++) {
      final ref = churchRef.collection('announcements').doc();
      batch.set(ref, {
        'churchId': churchId,
        'title': 'Announcement $i',
        'message': 'Announcement details $i',
        'status': 'published',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    }

    await batch.commit();
  }
}