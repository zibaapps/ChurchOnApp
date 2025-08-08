import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sermon.dart';
import '../services/sermons_service.dart';
import 'tenant_providers.dart';

final sermonsServiceProvider = Provider<SermonsService>((ref) => SermonsService());

final sermonsStreamProvider = StreamProvider<List<Sermon>>((ref) {
  final churchId = ref.watch(activeChurchIdProvider);
  if (churchId == null) {
    return const Stream.empty();
  }
  return ref.watch(sermonsServiceProvider).streamSermons(churchId);
});