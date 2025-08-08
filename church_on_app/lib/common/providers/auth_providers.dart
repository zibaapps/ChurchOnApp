import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

final currentUserProvider = StateProvider<AppUser>((ref) => AppUser.guest());

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.role == AppRole.admin || user.role == AppRole.superAdmin;
});

final isSuperAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.role == AppRole.superAdmin;
});