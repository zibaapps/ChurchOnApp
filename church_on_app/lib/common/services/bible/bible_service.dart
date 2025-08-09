import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/bible_annotation.dart';

class BibleService {
  BibleService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ann(String uid) => _firestore.collection('users').doc(uid).collection('bible_annotations');
  CollectionReference<Map<String, dynamic>> _plans(String uid) => _firestore.collection('users').doc(uid).collection('reading_plans');

  Stream<List<BibleAnnotation>> streamAnnotations(String uid, {String? book, int? chapter}) {
    Query<Map<String, dynamic>> q = _ann(uid);
    if (book != null) q = q.where('book', isEqualTo: book);
    if (chapter != null) q = q.where('chapter', isEqualTo: chapter);
    return q.orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => BibleAnnotation.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addBookmark({required String uid, required String version, required String book, required int chapter, required int verse}) async {
    await _ann(uid).add({
      'userId': uid,
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'type': AnnotationType.bookmark.name,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> addHighlight({required String uid, required String version, required String book, required int chapter, required int verse, required String colorHex}) async {
    await _ann(uid).add({
      'userId': uid,
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'type': AnnotationType.highlight.name,
      'colorHex': colorHex,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> addNote({required String uid, required String version, required String book, required int chapter, required int verse, required String text}) async {
    await _ann(uid).add({
      'userId': uid,
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'type': AnnotationType.note.name,
      'text': text,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // Reading plans
  Future<String> createPlan(String uid, {required String name}) async {
    final doc = await _plans(uid).add({
      'name': name,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'progress': <String, dynamic>{}, // key: yyyy-mm-dd -> completed: true
      'streak': 0,
      'reminderHour': 6,
    });
    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> streamPlans(String uid) {
    return _plans(uid).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> markPlanDay(String uid, String planId, DateTime day) async {
    final ref = _plans(uid).doc(planId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
      final progress = Map<String, dynamic>.from(data['progress'] as Map? ?? {});
      final key = DateTime.utc(day.year, day.month, day.day).toIso8601String().substring(0, 10);
      progress[key] = true;

      // compute streak
      int streak = 0;
      DateTime cursor = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      while (true) {
        final k = cursor.toIso8601String().substring(0, 10);
        if (progress[k] == true) {
          streak += 1;
          cursor = cursor.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      txn.set(ref, {'progress': progress, 'streak': streak, 'updatedAt': DateTime.now().toUtc().toIso8601String()}, SetOptions(merge: true));
    });
  }
}