import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/membership.dart';
import '../services/domain_service.dart';
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

final activeChurchIdProvider = StateProvider<String?>((ref) => null);

final domainResolvedChurchProvider = FutureProvider<String?>((ref) async {
  return DomainService().resolveChurchIdFromHost();
});

final tenantBootstrapProvider = FutureProvider<void>((ref) async {
  final domainChurch = await ref.read(domainResolvedChurchProvider.future);
  if (domainChurch != null) {
    ref.read(activeChurchIdProvider.notifier).state = domainChurch;
    return;
  }
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  if (user?.churchId != null) {
    ref.read(activeChurchIdProvider.notifier).state = user!.churchId;
    return;
  }
  final memberships = await ref.read(membershipsProvider.future);
  if (memberships.isNotEmpty) {
    ref.read(activeChurchIdProvider.notifier).state = memberships.first.churchId;
  }
});