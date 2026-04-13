import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../features/home/home_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../features/talk/talk_screen.dart';
import '../../features/phrases/phrases_screen.dart';
import '../../features/id_card/id_card_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/bottom_nav.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeHome,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return BottomNavScaffold(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppConstants.routeHome,
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeEmergency,
          name: 'emergency',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EmergencyScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeTalk,
          name: 'talk',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TalkScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routePhrases,
          name: 'phrases',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PhrasesScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeIdCard,
          name: 'id-card',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: IdCardScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeLearn,
          name: 'learn',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LearnScreen(),
          ),
        ),
        GoRoute(
          path: AppConstants.routeSettings,
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
