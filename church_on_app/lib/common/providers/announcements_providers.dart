import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/announcement.dart';
import '../services/announcement_service.dart';
import 'auth_providers.dart';

final announcementServiceProvider = Provider<AnnouncementService>((ref) => AnnouncementService());

final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId == null) return const Stream.empty();
  return ref.watch(announcementServiceProvider).streamAnnouncements(churchId);
});