import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/news_item.dart';
import '../services/news_service.dart';
import 'tenant_providers.dart';

final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

final newsStreamProvider = StreamProvider<List<NewsItem>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) return const Stream.empty();
  return ref.watch(newsServiceProvider).streamNews(churchId);
});