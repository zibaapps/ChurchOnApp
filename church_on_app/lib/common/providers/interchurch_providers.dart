import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/interchurch_service.dart';
import '../models/interchurch.dart';
import 'tenant_providers.dart';

final interchurchServiceProvider = Provider<InterchurchService>((ref) => InterchurchService());

final interchurchActivitiesForParticipantProvider = StreamProvider<List<InterchurchActivity>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) return const Stream.empty();
  return ref.watch(interchurchServiceProvider).streamActivitiesForParticipant(churchId);
});

final yearProgramEntriesProvider = StreamProvider<List<YearProgramEntry>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) return const Stream.empty();
  return ref.watch(interchurchServiceProvider).streamPublishedProgramEntriesForChurch(churchId);
});