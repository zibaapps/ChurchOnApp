import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final currentUserStreamProvider = StreamProvider<AppUser?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authUserStream();
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  if (user == null) return false;
  return user.role == AppRole.admin || user.role == AppRole.superAdmin;
});

final isSuperAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserStreamProvider).valueOrNull;
  if (user == null) return false;
  return user.role == AppRole.superAdmin;
});