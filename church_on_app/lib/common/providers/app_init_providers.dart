import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/messaging_service.dart';
import '../services/firestore_init.dart';
import '../services/remote_config_service.dart';
import 'auth_providers.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) => MessagingService());
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) => RemoteConfigService());

final appInitProvider = FutureProvider<void>((ref) async {
  await FirestoreInit.enablePersistence();
  await ref.read(messagingServiceProvider).initialize();
  await ref.read(remoteConfigServiceProvider).initialize();
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  final churchId = user?.churchId;
  if (churchId != null) {
    await ref.read(messagingServiceProvider).subscribeToChurchTopics(churchId);
  }
});