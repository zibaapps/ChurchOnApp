import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sermon.dart';
import '../services/sermons_service.dart';
import 'auth_providers.dart';

final sermonsServiceProvider = Provider<SermonsService>((ref) => SermonsService());

final sermonsStreamProvider = StreamProvider<List<Sermon>>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId == null) {
    return const Stream.empty();
  }
  return ref.watch(sermonsServiceProvider).streamSermons(churchId);
});