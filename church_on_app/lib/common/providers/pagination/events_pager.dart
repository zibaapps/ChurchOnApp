import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/event.dart';
import '../../models/page_result.dart';
import '../events_providers.dart';
import '../tenant_providers.dart';

class EventsPageState {
  const EventsPageState({this.items = const [], this.loading = false, this.hasMore = true, this.lastDoc});
  final List<EventItem> items;
  final bool loading;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;

  EventsPageState copyWith({List<EventItem>? items, bool? loading, bool? hasMore, DocumentSnapshot? lastDoc}) =>
      EventsPageState(items: items ?? this.items, loading: loading ?? this.loading, hasMore: hasMore ?? this.hasMore, lastDoc: lastDoc ?? this.lastDoc);
}

class EventsPager extends StateNotifier<EventsPageState> {
  EventsPager(this._read) : super(const EventsPageState());
  final Ref _read;
  static const int pageSize = 20;

  Future<void> loadInitial() async {
    if (state.loading) return;
    state = state.copyWith(loading: true);
    final churchId = _read.read(activeChurchIdProvider);
    if (churchId == null) {
      state = state.copyWith(items: [], loading: false, hasMore: false, lastDoc: null);
      return;
    }
    final PageResult<EventItem> page = await _read.read(eventsServiceProvider).fetchUpcomingEventsPage(churchId, limit: pageSize);
    state = EventsPageState(items: page.items, loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true);
    final churchId = _read.read(activeChurchIdProvider);
    if (churchId == null) {
      state = state.copyWith(loading: false);
      return;
    }
    final PageResult<EventItem> page = await _read.read(eventsServiceProvider).fetchUpcomingEventsPage(churchId, limit: pageSize, startAfter: state.lastDoc);
    state = state.copyWith(items: [...state.items, ...page.items], loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }
}

final eventsPagerProvider = StateNotifierProvider<EventsPager, EventsPageState>((ref) {
  final pager = EventsPager(ref);
  pager.loadInitial();
  return pager;
});