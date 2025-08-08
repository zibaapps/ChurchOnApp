import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../services/events_service.dart';
import 'auth_providers.dart';

final eventsServiceProvider = Provider<EventsService>((ref) => EventsService());

final eventsStreamProvider = StreamProvider<List<EventItem>>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId == null) {
    return const Stream.empty();
  }
  return ref.watch(eventsServiceProvider).streamUpcomingEvents(churchId);
});