import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/age_selection_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/worlds/worlds_map_screen.dart';
import '../../presentation/screens/worlds/realm_screen.dart';
import '../../presentation/screens/challenge/challenge_screen.dart';
import '../../presentation/screens/challenge/challenge_result_screen.dart';
import '../../presentation/screens/coach/coach_screen.dart';
import '../../presentation/screens/leaderboard/leaderboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/multiplayer/multiplayer_screen.dart';
import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/parent/parent_dashboard_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String ageSelection = '/age-selection';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String worlds = '/worlds';
  static const String realm = '/realm/:realmId';
  static const String challenge = '/challenge/:challengeId';
  static const String challengeResult = '/challenge-result';
  static const String coach = '/coach';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String multiplayer = '/multiplayer';
  static const String achievements = '/achievements';
  static const String parentDashboard = '/parent';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.ageSelection,
      builder: (context, state) => const AgeSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.worlds,
              builder: (context, state) => const WorldsMapScreen(),
              routes: [
                GoRoute(
                  path: 'realm/:realmId',
                  builder: (context, state) => RealmScreen(
                    realmId: state.pathParameters['realmId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.leaderboard,
              builder: (context, state) => const LeaderboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/challenge/:challengeId',
      builder: (context, state) => ChallengeScreen(
        challengeId: state.pathParameters['challengeId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.challengeResult,
      builder: (context, state) => ChallengeResultScreen(
        extra: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: AppRoutes.coach,
      builder: (context, state) => const CoachScreen(),
    ),
    GoRoute(
      path: AppRoutes.multiplayer,
      builder: (context, state) => const MultiplayerScreen(),
    ),
    GoRoute(
      path: AppRoutes.achievements,
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: AppRoutes.parentDashboard,
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
