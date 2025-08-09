import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final appConfigStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  return FirebaseFirestore.instance.collection('app_config').doc('general').snapshots().map((d) => d.data());
});

final supportEmailProvider = Provider<String>((ref) {
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return (data?['supportEmail'] as String?) ?? 'support@churchapp.cloud';
});

final supportPhoneProvider = Provider<String>((ref) {
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return (data?['supportPhone'] as String?) ?? '+260968551110';
});

final domainProvider = Provider<String>((ref) {
  final data = ref.watch(appConfigStreamProvider).valueOrNull;
  return (data?['domain'] as String?) ?? 'churchapp.cloud';
});

final zipModeEnabledProvider = StreamProvider.family<bool, String>((ref, churchId) {
  return FirebaseFirestore.instance.collection('churches').doc(churchId).snapshots().map((d) => (d.data()?['zipMode']?['enabled'] as bool?) ?? false);
});