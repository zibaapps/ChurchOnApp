import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/auth_providers.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final userAsync = ref.watch(currentUserStreamProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isSuper = ref.watch(isSuperAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            if (user == null) {
              return Center(
                child: FilledButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Login / Register'),
                ),
              );
            }
            return ListView(
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
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.church),
                  title: Text(user.churchId == null ? 'No church selected' : 'Church: ${user.churchId}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/onboarding/church'),
                ),
                const Divider(),
                if (isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Panel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Billing'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin/billing'),
                  ),
                ],
                if (isSuper)
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Super Admin'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/superadmin'),
                  ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => auth.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}