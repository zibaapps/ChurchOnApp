import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/invite_card.dart';

class InviteService {
  InviteService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<List<InviteCard>> streamInvites(String churchId) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('invites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InviteCard.fromDoc(d.id, d.data())).toList());
  }

  Future<void> addInvite(String churchId, InviteCard card) async {
    await _firestore.collection('churches').doc(churchId).collection('invites').add(card.toMap());
  }
}