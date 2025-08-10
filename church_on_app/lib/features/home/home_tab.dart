import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/app_logo.dart';
import '../../common/providers/tenant_info_providers.dart';
import '../../common/providers/sermons_providers.dart';
import '../../common/providers/events_providers.dart';
import '../../common/providers/news_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(tenantDisplayNameProvider);
    final sermons = ref.watch(sermonsStreamProvider);
    final events = ref.watch(eventsStreamProvider);
    final news = ref.watch(newsStreamProvider);

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
              _QuickCard(icon: Icons.play_circle, label: 'Sermons', onTap: () {}),
              _QuickCard(icon: Icons.event, label: 'Programs', onTap: () => context.push('/programs/year')),
              _QuickCard(icon: Icons.volunteer_activism, label: 'Give', onTap: () => context.push('/payments')),
              _QuickCard(icon: Icons.forum, label: 'Connect', onTap: () => context.push('/connect/chat')),
            ],
          ),
        ),
        // Featured Sermons
        SliverToBoxAdapter(
          child: _SectionHeader(title: 'Featured Sermons'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: sermons.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                final top = items.take(10).toList();
                if (top.isEmpty) return const Center(child: Text('No sermons yet'));
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final s = top[i];
                    return _ChipCard(
                      icon: Icons.play_circle_outline,
                      title: s.title,
                      onTap: () => context.push('/sermons/${s.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Featured Events
        SliverToBoxAdapter(child: _SectionHeader(title: 'Upcoming Events')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: events.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                final top = items.take(10).toList();
                if (top.isEmpty) return const Center(child: Text('No events yet'));
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final ev = top[i];
                    return _ChipCard(
                      icon: Icons.event,
                      title: ev.name,
                      onTap: () => context.push('/programs/year'),
                    );
                  },
                );
              },
            ),
          ),
        ),
        // Featured News
        SliverToBoxAdapter(child: _SectionHeader(title: 'Latest News')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 140,
            child: news.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                final top = items.take(10).toList();
                if (top.isEmpty) return const Center(child: Text('No news'));
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final n = top[i];
                    return SizedBox(
                      width: 220,
                      child: Card(
                        child: InkWell(
                          onTap: () => context.push('/news'),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image, size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    n.headline,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}