import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news_item.dart';
import '../services/news_service.dart';
import 'auth_providers.dart';

final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

final newsStreamProvider = StreamProvider<List<NewsItem>>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId == null) return const Stream.empty();
  return ref.watch(newsServiceProvider).streamNews(churchId);
});