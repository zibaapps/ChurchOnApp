import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/interchurch.dart';

class InterchurchService {
  InterchurchService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

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
}