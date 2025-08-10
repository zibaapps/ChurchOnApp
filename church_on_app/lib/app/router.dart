import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../features/admin/add_sermon_screen.dart';
import '../features/admin/add_event_screen.dart';
import '../features/admin/add_announcement_screen.dart';
import '../features/admin/add_news_screen.dart';
import '../features/admin/add_report_screen.dart';
import '../features/admin/tenant_settings_screen.dart';
import '../features/invites/invite_list_screen.dart';
import '../features/admin/add_invite_screen.dart';
import '../features/interchurch/interchurch_events_screen.dart';
import '../features/interchurch/interchurch_projects_screen.dart';
import '../features/interchurch/interchurch_invite_screen.dart';
import '../features/programs/year_program_screen.dart';
import '../features/moderation/moderation_screen.dart';
import '../features/payments/payment_screen.dart';
import '../features/memberships/membership_admin_screen.dart';
import '../features/tour/app_tour_screen.dart';
import '../common/providers/auth_providers.dart';
import '../features/sermons/sermon_detail_screen.dart';
import '../features/announcements/announcements_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_room_screen.dart';
import '../features/news/news_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/reports/service_issues_screen.dart';
import '../features/churches/nearby_churches_screen.dart';
import '../features/games/bible_quiz_screen.dart';
import '../features/games/memory_match_screen.dart';
import '../features/games/verse_scramble_screen.dart';
import '../features/games/leaderboard_screen.dart';
import '../features/give/tithes_admin_screen.dart';
import '../features/bible/bible_screen.dart';
import '../features/bible/bible_cache_screen.dart';
import '../features/bible/reading_plans_screen.dart';
import '../features/support/support_screen.dart';
import '../features/support/report_problem_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/accessibility_settings_screen.dart';
import '../features/settings/two_factor_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/sermons/:id',
      builder: (context, state) {
        // churchId is derived from the current user context inside the screen if needed
        // For now, we pass an empty churchId and let the screen fetch via user context or adjust later.
        final id = state.pathParameters['id']!;
        return _SermonDetailRouteProxy(sermonId: id);
      },
    ),
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
    GoRoute(path: '/admin/add-sermon', builder: (c, s) => const AddSermonScreen()),
    GoRoute(path: '/admin/add-event', builder: (c, s) => const AddEventScreen()),
    GoRoute(path: '/admin/add-announcement', builder: (c, s) => const AddAnnouncementScreen()),
    GoRoute(path: '/admin/add-news', builder: (c, s) => const AddNewsScreen()),
    GoRoute(path: '/admin/add-report', builder: (c, s) => const AddReportScreen()),
    GoRoute(path: '/admin/tenant-settings', builder: (c, s) => const TenantSettingsScreen()),
    GoRoute(path: '/invites', builder: (c, s) => const InviteListScreen()),
    GoRoute(path: '/interchurch/events', builder: (c, s) => const InterchurchEventsScreen()),
    GoRoute(path: '/interchurch/projects', builder: (c, s) => const InterchurchProjectsScreen()),
    GoRoute(path: '/interchurch/invite', builder: (c, s) => InterchurchInviteScreen(activityId: (s.extra as String?) ?? '')),
    GoRoute(path: '/programs/year', builder: (c, s) => const YearProgramScreen()),
    GoRoute(path: '/moderation', builder: (c, s) => const ModerationScreen()),
    GoRoute(path: '/payments', builder: (c, s) => const PaymentScreen()),
    GoRoute(path: '/admin/tithes', builder: (c, s) => const TithesAdminScreen()),
    GoRoute(path: '/tour', builder: (c, s) => const AppTourScreen()),
    GoRoute(path: '/admin/memberships', builder: (c, s) => const MembershipAdminScreen()),
    GoRoute(path: '/admin/add-invite', builder: (c, s) => const AddInviteScreen()),
    GoRoute(path: '/connect/chat', builder: (c, s) => const ChatListScreen()),
    GoRoute(path: '/churches/nearby', builder: (c, s) => const NearbyChurchesScreen()),
    GoRoute(path: '/connect/games', builder: (c, s) => const BibleQuizScreen()),
    GoRoute(path: '/connect/games/memory', builder: (c, s) => const MemoryMatchScreen()),
    GoRoute(path: '/connect/games/scramble', builder: (c, s) => const VerseScrambleScreen()),
    GoRoute(path: '/connect/games/leaderboard', builder: (c, s) => const LeaderboardScreen()),
    GoRoute(path: '/chat/:id', builder: (c, s) => ChatRoomScreen(threadId: s.pathParameters['id']!)),
    GoRoute(path: '/connect/testimonies', builder: (c, s) => const _PlaceholderPage(title: 'Testimonies')),
    GoRoute(path: '/connect/prayers', builder: (c, s) => const _PlaceholderPage(title: 'Prayer Requests')),
    GoRoute(path: '/announcements', builder: (c, s) => const AnnouncementsScreen()),
    GoRoute(path: '/news', builder: (c, s) => const NewsScreen()),
    GoRoute(path: '/reports', builder: (c, s) => const ReportsScreen()),
    GoRoute(path: '/reports/issues', builder: (c, s) => const ServiceIssuesScreen()),
    GoRoute(path: '/bible', builder: (c, s) => const BibleScreen()),
    GoRoute(path: '/bible/cache', builder: (c, s) => const BibleCacheScreen()),
    GoRoute(path: '/bible/plans', builder: (c, s) => const ReadingPlansScreen()),
    GoRoute(path: '/support', builder: (c, s) => const SupportScreen()),
    GoRoute(path: '/support/report', builder: (c, s) => const ReportProblemScreen()),
    GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
    GoRoute(path: '/settings/accessibility', builder: (c, s) => const AccessibilitySettingsScreen()),
    GoRoute(path: '/settings/2fa', builder: (c, s) => const TwoFactorScreen()),
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

class _SermonDetailRouteProxy extends ConsumerWidget {
  const _SermonDetailRouteProxy({required this.sermonId});
  final String sermonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user?.churchId == null) {
      return const _PlaceholderPage(title: 'Select a church to view sermons');
    }
    return SermonDetailScreen(churchId: user!.churchId!, sermonId: sermonId);
  }
}