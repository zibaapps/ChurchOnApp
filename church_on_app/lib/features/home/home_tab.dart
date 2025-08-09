import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _pageController = PageController(viewportFraction: 0.9);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (t) {
      if (!_pageController.hasClients) return;
      final next = ((_pageController.page ?? 0).round() + 1) % 5;
      _pageController.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SuperadminAdsCarousel(controller: _pageController),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/ar/scan'),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('AR Church Experience'),
          ),
          const SizedBox(height: 16),
          const _Section(title: 'Featured Sermon'),
          const SizedBox(height: 12),
          const _Section(title: 'Upcoming Events'),
          const SizedBox(height: 12),
          const _Section(title: 'Announcements'),
          const SizedBox(height: 12),
          const _Section(title: 'Church News'),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Church Reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/reports'),
          ),
        ],
      ),
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