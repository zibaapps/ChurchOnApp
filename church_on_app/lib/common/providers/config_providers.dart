import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_init_providers.dart';

final appConfigStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return FirebaseFirestore.instance.collection('app_config').doc('general').snapshots().map((d) => d.data());
});

final supportEmailProvider = Provider<String>((ref) {
  final rc = ref.watch(remoteConfigServiceProvider);
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return rc.supportEmail.isNotEmpty ? rc.supportEmail : ((data?['supportEmail'] as String?) ?? 'support@churchapp.cloud');
});

final supportPhoneProvider = Provider<String>((ref) {
  final rc = ref.watch(remoteConfigServiceProvider);
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return rc.supportPhone.isNotEmpty ? rc.supportPhone : ((data?['supportPhone'] as String?) ?? '+260968551110');
});

final domainProvider = Provider<String>((ref) {
  final rc = ref.watch(remoteConfigServiceProvider);
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return rc.domain.isNotEmpty ? rc.domain : ((data?['domain'] as String?) ?? 'churchapp.cloud');
});

final zipModeEnabledProvider = StreamProvider.family<bool, String>((ref, churchId) {
  return FirebaseFirestore.instance.collection('churches').doc(churchId).snapshots().map((d) => (d.data()?['zipMode']?['enabled'] as bool?) ?? false);
});