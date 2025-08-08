import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/widgets/home_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/church_select_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/ar/ar_scan_screen.dart';
import '../features/ar/ar_view_screen.dart';
import '../features/admin/admin_panel_screen.dart';
import '../features/admin/billing_panel_screen.dart';
import '../features/admin/super_admin_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/church',
      builder: (context, state) => const ChurchSelectScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(path: '/admin', builder: (c, s) => const AdminPanelScreen()),
    GoRoute(path: '/admin/billing', builder: (c, s) => const BillingPanelScreen()),
    GoRoute(path: '/superadmin', builder: (c, s) => const SuperAdminScreen()),
    GoRoute(path: '/connect/chat', builder: (c, s) => const _PlaceholderPage(title: 'Chat Rooms')),
    GoRoute(path: '/connect/testimonies', builder: (c, s) => const _PlaceholderPage(title: 'Testimonies')),
    GoRoute(path: '/connect/prayers', builder: (c, s) => const _PlaceholderPage(title: 'Prayer Requests')),
    GoRoute(
      path: '/ar/scan',
      builder: (context, state) => const ArScanScreen(),
    ),
    GoRoute(
      path: '/ar/view',
      builder: (context, state) => ArViewScreen(modelUrl: state.extra as String?),
    ),
  ],
);

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming soon')),
    );
  }
}