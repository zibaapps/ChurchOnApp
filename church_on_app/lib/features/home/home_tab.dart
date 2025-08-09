import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/widgets/upcoming_strip.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/providers/tenant_info_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(tenantDisplayNameProvider);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 180,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.only(top: 40),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 72),
                  const SizedBox(height: 8),
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _QuickCard(icon: Icons.play_circle, label: 'Sermons', onTap: () => context.push('/sermons/featured')),
              _QuickCard(icon: Icons.event, label: 'Events', onTap: () => context.push('/events')),
              _QuickCard(icon: Icons.volunteer_activism, label: 'Give', onTap: () => context.push('/payments')),
              _QuickCard(icon: Icons.forum, label: 'Connect', onTap: () => context.push('/connect/chat')),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuperadminAdsCarousel extends StatelessWidget {
  const _SuperadminAdsCarousel({required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('superadmin_ads').orderBy('priority').snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          if (docs.isEmpty) return const SizedBox.shrink();
          return PageView.builder(
            controller: controller,
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final image = d['imageUrl'] as String?;
              final url = d['linkUrl'] as String?;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: url == null ? null : () async {
                    final uri = Uri.tryParse(url);
                    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (image != null)
                          Image.network(image, fit: BoxFit.cover)
                        else
                          Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black45,
                            child: Text(
                              d['title']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}