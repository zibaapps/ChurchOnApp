import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/news_item.dart';
import '../../models/page_result.dart';
import '../news_providers.dart';
import '../tenant_providers.dart';

class NewsPageState {
  const NewsPageState({this.items = const [], this.loading = false, this.hasMore = true, this.lastDoc});
  final List<NewsItem> items;
  final bool loading;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;

  NewsPageState copyWith({List<NewsItem>? items, bool? loading, bool? hasMore, DocumentSnapshot? lastDoc}) =>
      NewsPageState(items: items ?? this.items, loading: loading ?? this.loading, hasMore: hasMore ?? this.hasMore, lastDoc: lastDoc ?? this.lastDoc);
}

class NewsPager extends StateNotifier<NewsPageState> {
  NewsPager(this._read) : super(const NewsPageState());
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
    final PageResult<NewsItem> page = await _read.read(newsServiceProvider).fetchNewsPage(churchId, limit: pageSize);
    state = NewsPageState(items: page.items, loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true);
    final churchId = _read.read(activeChurchIdProvider);
    if (churchId == null) {
      state = state.copyWith(loading: false);
      return;
    }
    final PageResult<NewsItem> page = await _read.read(newsServiceProvider).fetchNewsPage(churchId, limit: pageSize, startAfter: state.lastDoc);
    state = state.copyWith(items: [...state.items, ...page.items], loading: false, hasMore: page.hasMore, lastDoc: page.lastDoc);
  }
}

final newsPagerProvider = StateNotifierProvider<NewsPager, NewsPageState>((ref) {
  final pager = NewsPager(ref);
  pager.loadInitial();
  return pager;
});