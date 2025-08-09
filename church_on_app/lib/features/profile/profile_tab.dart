import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/providers/config_providers.dart';
import '../../common/services/security_service.dart';
import 'emergency_contacts_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final userAsync = ref.watch(currentUserStreamProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isSuper = ref.watch(isSuperAdminProvider);
    final memberships = ref.watch(membershipsProvider).valueOrNull ?? const [];
    final activeChurchId = ref.watch(activeChurchIdProvider);

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
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text('Support: ${ref.watch(supportEmailProvider)} • ${ref.watch(supportPhoneProvider)}'),
                DropdownButtonFormField<String>(
                  value: activeChurchId,
                  items: [
                    for (final m in memberships)
                      DropdownMenuItem(value: m.churchId, child: Text(m.churchId))
                  ],
                  onChanged: (v) => ref.read(activeChurchIdProvider.notifier).state = v,
                  decoration: const InputDecoration(labelText: 'Active Church'),
                ),
                const Divider(),
                if (isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Panel'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin'),
                  ),
                  SwitchListTile(
                    title: const Text('Zip Mode (Emergency Lockdown)'),
                    subtitle: const Text('Temporarily restrict app access for this church'),
                    value: false,
                    onChanged: (v) async {
                      final churchId = activeChurchId;
                      if (churchId == null) return;
                      final svc = ZipModeService();
                      if (v) {
                        await svc.enable(churchId: churchId, reason: 'Admin enabled via Profile');
                      } else {
                        await svc.disable(churchId: churchId);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Zip Mode ${v ? 'Enabled' : 'Disabled'}')));
                      }
                    },
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
                _ShakeSosTile(),
                ListTile(
                  leading: const Icon(Icons.contacts),
                  title: const Text('Emergency Contacts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmergencyContactsScreen())),
                ),
                ListTile(
                  leading: const Icon(Icons.help_center),
                  title: const Text('Support & Docs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/support'),
                ),
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

class _ShakeSosTile extends StatefulWidget {
  @override
  State<_ShakeSosTile> createState() => _ShakeSosTileState();
}

class _ShakeSosTileState extends State<_ShakeSosTile> {
  bool _enabled = false;
  final _svc = ShakeSosService();

  @override
  void dispose() {
    _svc.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Shake to SOS'),
      subtitle: const Text('Shake device to call and text emergency contacts'),
      value: _enabled,
      onChanged: (v) async {
        setState(() => _enabled = v);
        if (v) {
          final uid = (ModalRoute.of(context)?.settings as dynamic)?.arguments as String?; // not used here
          _svc.startListening(
            getEmergencyNumbers: () async {
              // Load latest from Firestore via service screen if needed; for now the SOS will fall back automatically
              return const <String>[];
            },
            defaultNumber: '+260968551110',
          );
        } else {
          _svc.stopListening();
        }
      },
    );
  }
}