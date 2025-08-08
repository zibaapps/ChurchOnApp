import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Stream<List<ChatThread>> streamThreads(String churchId, String uid) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('threads')
        .where('memberUids', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatThread.fromDoc(d.id, d.data())).toList());
  }

  Stream<List<ChatMessage>> streamMessages(String churchId, String threadId) {
    return _firestore
        .collection('churches')
        .doc(churchId)
        .collection('threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromDoc(d.id, d.data())).toList());
  }

  Future<String> createThread(String churchId, ChatThread thread) async {
    final ref = await _firestore.collection('churches').doc(churchId).collection('threads').add(thread.toMap());
    return ref.id;
  }

  Future<void> sendMessage(String churchId, String threadId, ChatMessage msg) async {
    final ref = _firestore.collection('churches').doc(churchId).collection('threads').doc(threadId);
    await _firestore.runTransaction((txn) async {
      txn.set(ref.collection('messages').doc(), msg.toMap());
      txn.update(ref, {'lastMessage': msg.text, 'updatedAt': msg.sentAt.toUtc().toIso8601String()});
    });
  }

  Future<void> toggleReaction({
    required String churchId,
    required String threadId,
    required String messageId,
    required String emoji,
    required String uid,
  }) async {
    final ref = _firestore.collection('churches').doc(churchId).collection('threads').doc(threadId).collection('messages').doc(messageId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
      final reactions = Map<String, dynamic>.from(data['reactions'] as Map? ?? {});
      final list = (reactions[emoji] as List?)?.cast<String>() ?? <String>[];
      if (list.contains(uid)) {
        list.remove(uid);
      } else {
        list.add(uid);
      }
      reactions[emoji] = list;
      txn.update(ref, {'reactions': reactions});
    });
  }
}