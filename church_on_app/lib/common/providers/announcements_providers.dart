import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';
import 'tenant_providers.dart';

final announcementServiceProvider = Provider<AnnouncementService>((ref) => AnnouncementService());

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) return const Stream.empty();
  return ref.watch(announcementServiceProvider).streamAnnouncements(churchId);
});