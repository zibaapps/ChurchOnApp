import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/membership.dart';
import 'auth_providers.dart';

final membershipsProvider = StreamProvider<List<Membership>>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final uid = user?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('memberships')
      .orderBy('joinedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Membership.fromMap(d.data())).toList());
});

final activeChurchIdProvider = StateProvider<String?>((ref) {
  final currentUser = ref.watch(currentUserStreamProvider).valueOrNull;
  final memberships = ref.watch(membershipsProvider).valueOrNull ?? const <Membership>[];
  // prefer user's previous churchId if still a member; otherwise first membership
  final previous = currentUser?.churchId;
  if (previous != null && memberships.any((m) => m.churchId == previous)) {
    return previous;
  }
  return memberships.isNotEmpty ? memberships.first.churchId : null;
});