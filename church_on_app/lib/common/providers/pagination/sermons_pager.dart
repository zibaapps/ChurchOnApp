import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/sermon.dart';
import '../../models/page_result.dart';
import '../sermons_providers.dart';
import '../tenant_providers.dart';

class SermonsPageState {
  const SermonsPageState({this.items = const [], this.loading = false, this.hasMore = true, this.lastDoc});
  final List<Sermon> items;
  final bool loading;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;

  SermonsPageState copyWith({List<Sermon>? items, bool? loading, bool? hasMore, DocumentSnapshot? lastDoc}) =>
      SermonsPageState(items: items ?? this.items, loading: loading ?? this.loading, hasMore: hasMore ?? this.hasMore, lastDoc: lastDoc ?? this.lastDoc);
}

class SermonsPager extends StateNotifier<SermonsPageState> {
  SermonsPager(this._read) : super(const SermonsPageState());
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
    final PageResult<Sermon> page = await _read.read(sermonsServiceProvider).fetchSermonsPage(churchId, limit: pageSize);
    state = SermonsPageState(items: page.items, loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true);
    final churchId = _read.read(activeChurchIdProvider);
    if (churchId == null) {
      state = state.copyWith(loading: false);
      return;
    }
    final PageResult<Sermon> page = await _read.read(sermonsServiceProvider).fetchSermonsPage(churchId, limit: pageSize, startAfter: state.lastDoc);
    state = state.copyWith(items: [...state.items, ...page.items], loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }
}

final sermonsPagerProvider = StateNotifierProvider<SermonsPager, SermonsPageState>((ref) {
  final pager = SermonsPager(ref);
  pager.loadInitial();
  return pager;
});