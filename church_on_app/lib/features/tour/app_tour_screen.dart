import 'package:flutter/material.dart';

class AppTourScreen extends StatefulWidget {
  const AppTourScreen({super.key});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_TourPage> _pages = const [
    _TourPage(icon: Icons.church, title: 'Multi-tenant Churches', body: 'Separate spaces per church with custom branding.'),
    _TourPage(icon: Icons.play_circle, title: 'Sermons & Live', body: 'On-demand and live streams (YouTube, Facebook, Google Meet).'),
    _TourPage(icon: Icons.event, title: 'Events & QR Check-ins', body: 'Create events, RSVP, and check-in via QR.'),
    _TourPage(icon: Icons.forum, title: 'Connect & Prayer', body: 'Chat rooms, testimonies, and prayer requests.'),
    _TourPage(icon: Icons.volunteer_activism, title: 'Giving', body: 'MoMo & PayPal with auto fees (5% or K0.50 minimum).'),
    _TourPage(icon: Icons.campaign, title: 'Announcements & News', body: 'Publish/unpublish with moderation.'),
    _TourPage(icon: Icons.group, title: 'Membership & Roles', body: 'Invite via QR, manage roles per church.'),
    _TourPage(icon: Icons.public, title: 'Interchurch', body: 'Shared events, projects, and total giving across churches.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Church On App – Preview')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _pages.length,
              itemBuilder: (context, i) => _pages[i],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < _pages.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == i ? 12 : 8,
                    height: _index == i ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _index == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index == 0 ? null : () => _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _index == _pages.length - 1
                          ? () => Navigator.of(context).pop()
                          : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                      child: Text(_index == _pages.length - 1 ? 'Done' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(body, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}