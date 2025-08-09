import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/interchurch.dart';

class InterchurchService {
  InterchurchService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  // Legacy simple streams
  Stream<List<InterchurchEvent>> streamEvents() {
    return _firestore
        .collection('interchurch_events')
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map((d) => InterchurchEvent.fromDoc(d.id, d.data())).toList());
  }

  Stream<List<InterchurchProject>> streamProjects() {
    return _firestore
        .collection('interchurch_projects')
        .orderBy('title')
        .snapshots()
        .map((s) => s.docs.map((d) => InterchurchProject.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addProjectGiving(String projectId, double amount) async {
    await _firestore.collection('interchurch_projects').doc(projectId).update({'totalGiving': FieldValue.increment(amount)});
  }

  Stream<YearProgram> streamYearProgram(String churchId, int year) {
    return _firestore
        .collection('year_programs')
        .doc('${churchId}_$year')
        .snapshots()
        .map((d) => YearProgram.fromDoc(d.id, d.data() ?? {}));
  }

  // Unified Interchurch Activities
  CollectionReference<Map<String, dynamic>> get _activities => _firestore.collection('interchurch_activities');
  CollectionReference<Map<String, dynamic>> get _programEntries => _firestore.collection('year_program_entries');

  Future<String> createActivity(InterchurchActivity activity) async {
    final ref = await _activities.add(activity.toMap());
    return ref.id;
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    await _activities.doc(id).update(data);
  }

  Stream<List<InterchurchActivity>> streamActivitiesForLead(String leadChurchId) {
    return _activities.where('leadChurchId', isEqualTo: leadChurchId).snapshots().map(
          (s) => s.docs.map((d) => InterchurchActivity.fromDoc(d.id, d.data())).toList(),
        );
  }

  Stream<List<InterchurchActivity>> streamActivitiesForParticipant(String churchId) {
    return _activities.where('participants', arrayContainsAny: [churchId]).snapshots().map(
          (s) => s.docs.map((d) => InterchurchActivity.fromDoc(d.id, d.data())).toList(),
        );
  }

  Future<void> respondToInvite({required String activityId, required String churchId, required String decision}) async {
    final doc = _activities.doc(activityId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(doc);
      final data = snap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
      final statuses = Map<String, dynamic>.from(data['participantStatuses'] as Map? ?? {});
      statuses[churchId] = decision; // invited|accepted|declined
      txn.update(doc, {'participantStatuses': statuses});
    });
  }

  // Year Program Entries (flat collection powering Programs screen)
  Future<String> createProgramEntry(YearProgramEntry entry) async {
    final ref = await _programEntries.add(entry.toMap());
    return ref.id;
  }

  Future<void> updateProgramEntry(String id, Map<String, dynamic> data) async {
    await _programEntries.doc(id).update(data);
  }

  Stream<List<YearProgramEntry>> streamProgramEntriesForChurch(String churchId) {
    return _programEntries
        .where('participants', arrayContainsAny: [churchId])
        .snapshots()
        .map((s) => s.docs.map((d) => YearProgramEntry.fromDoc(d.id, d.data())).toList());
  }

  Stream<List<YearProgramEntry>> streamPublishedProgramEntriesForChurch(String churchId) {
    return _programEntries
        .where('participants', arrayContainsAny: [churchId])
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((s) => s.docs.map((d) => YearProgramEntry.fromDoc(d.id, d.data())).toList());
  }
}