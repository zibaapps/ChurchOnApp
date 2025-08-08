import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/models/app_user.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? 'User', style: Theme.of(context).textTheme.titleMedium),
                    Text(user.email ?? 'No email'),
                    Text('Role: ${user.role.name}')
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => ref.read(currentUserProvider.notifier).state = const AppUser(
                    uid: 'u1', email: 'admin@church.com', displayName: 'Admin User', role: AppRole.admin,
                  ),
                  child: const Text('Set Admin'),
                ),
                FilledButton.tonal(
                  onPressed: () => ref.read(currentUserProvider.notifier).state = const AppUser(
                    uid: 'u2', email: 'super@church.com', displayName: 'Super Admin', role: AppRole.superAdmin,
                  ),
                  child: const Text('Set SuperAdmin'),
                ),
                OutlinedButton(
                  onPressed: () => ref.read(currentUserProvider.notifier).state = AppUser.guest(),
                  child: const Text('Set Guest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}