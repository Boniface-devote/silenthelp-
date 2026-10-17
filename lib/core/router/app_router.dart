import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../features/talk/talk_screen.dart';
import '../../features/phrases/phrases_screen.dart';
import '../../features/id_card/id_card_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/settings/app_settings_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/emergency/trusted_circle_screen.dart';
import '../../features/emergency/nearby_places_screen.dart';
import '../../features/digital_safety/digital_safety_screen.dart';
import '../../features/digital_safety/abuse_report_screen.dart';
import '../../features/safety_plan/safety_plan_screen.dart';
import '../../shared/widgets/bottom_nav.dart';

// Check if onboarding is complete
Future<bool> _isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  redirect: (context, state) async {
    final isComplete = await _isOnboardingComplete();
    final isGoingToOnboarding = state.uri.path == '/onboarding';

    // If onboarding is not complete and not already going to onboarding, redirect
    if (!isComplete && !isGoingToOnboarding) {
      return '/onboarding';
    }

    // If onboarding is complete and trying to go to onboarding, redirect to home
    if (isComplete && isGoingToOnboarding) {
      return AppConstants.routeHome;
    }

    return null;
  },
  routes: [
    // Onboarding route (outside ShellRoute so no bottom nav)
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: OnboardingScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: AppConstants.routeHome,
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppConstants.routeEmergency,
          name: 'emergency',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: EmergencyScreen()),
        ),
        GoRoute(
          path: AppConstants.routeTalk,
          name: 'talk',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TalkScreen()),
        ),
        GoRoute(
          path: AppConstants.routePhrases,
          name: 'phrases',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PhrasesScreen()),
        ),
        GoRoute(
          path: AppConstants.routeIdCard,
          name: 'id-card',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: IdCardScreen()),
        ),
        GoRoute(
          path: AppConstants.routeLearn,
          name: 'learn',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LearnScreen()),
        ),
        GoRoute(
          path: AppConstants.routeSettings,
          name: 'settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AppSettingsScreen()),
        ),
        GoRoute(
          path: AppConstants.routeProfile,
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
        GoRoute(
          path: AppConstants.routeTrustedCircle,
          name: 'trusted-circle',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TrustedCircleScreen()),
        ),
        GoRoute(
          path: AppConstants.routeNearbyPlaces,
          name: 'nearby-places',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NearbyPlacesScreen()),
        ),
        GoRoute(
          path: AppConstants.routeDigitalSafety,
          name: 'digital-safety',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DigitalSafetyScreen()),
        ),
        GoRoute(
          path: AppConstants.routeAbuseReport,
          name: 'abuse-report',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AbuseReportScreen()),
        ),
        GoRoute(
          path: AppConstants.routeSafetyPlan,
          name: 'safety-plan',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SafetyPlanScreen()),
        ),
      ],
    ),
  ],
);
