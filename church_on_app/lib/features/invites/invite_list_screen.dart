import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/tenant_providers.dart';
import '../../common/services/invite_service.dart';
import '../../common/models/invite_card.dart';

class InviteListScreen extends ConsumerWidget {
  const InviteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churchId = ref.watch(activeChurchIdProvider);
    if (churchId == null) {
      return const Scaffold(body: Center(child: Text('No active church')));
    }
    final stream = InviteService().streamInvites(churchId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Cards'),
        actions: [
          IconButton(
            tooltip: 'Test Deep Link',
            icon: const Icon(Icons.link),
            onPressed: () => context.go('/onboarding?invite=DEMO123'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/admin/add-invite'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<InviteCard>>(
        stream: stream,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <InviteCard>[];
          if (items.isEmpty) return const Center(child: Text('No invites'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(c.title),
                  subtitle: Text(c.isOnline ? 'Online' : (c.location ?? '')),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      final link = c.qrData; // placeholder: use as share link
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied: $link')));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}