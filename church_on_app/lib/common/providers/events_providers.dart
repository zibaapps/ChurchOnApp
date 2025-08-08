import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../services/events_service.dart';
import 'tenant_providers.dart';

final eventsServiceProvider = Provider<EventsService>((ref) => EventsService());

final eventsStreamProvider = StreamProvider<List<EventItem>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) {
    return const Stream.empty();
  }
  return ref.watch(eventsServiceProvider).streamUpcomingEvents(churchId);
});