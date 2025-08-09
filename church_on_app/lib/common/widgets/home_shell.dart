import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tenant_providers.dart';
import '../providers/config_providers.dart';
import '../../features/home/home_tab.dart';
import '../../features/sermons/sermons_tab.dart';
import '../../features/connect/connect_tab.dart';
import '../../features/give/give_tab.dart';
import '../../features/events/events_tab.dart';
import '../../features/profile/profile_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    SermonsTab(),
    ConnectTab(),
    GiveTab(),
    EventsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final churchId = ref.watch(activeChurchIdProvider);
    final zip = churchId == null ? const AsyncValue<bool>.data(false) : ref.watch(zipModeEnabledProvider(churchId));
    final locked = zip.valueOrNull == true;

    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: locked,
            child: IndexedStack(
              index: _currentIndex,
              children: _tabs,
            ),
          ),
          if (locked)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Material(
                color: Colors.amber.shade700,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.black),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Zip Mode is active. App access is temporarily restricted for safety.', style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Sermons'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Connect'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Give'),
          NavigationDestination(icon: Icon(Icons.event_available_outlined), selectedIcon: Icon(Icons.event_available), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}