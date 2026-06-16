import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/challenge_repository.dart';
import 'data/repositories/leaderboard_repository.dart';
import 'data/repositories/coach_repository.dart';
import 'presentation/blocs/user/user_cubit.dart';
import 'presentation/blocs/auth/auth_cubit.dart';
import 'presentation/blocs/leaderboard/leaderboard_cubit.dart';
import 'presentation/blocs/coach/coach_cubit.dart';

class ThinkoraApp extends StatefulWidget {
  const ThinkoraApp({super.key});

  @override
  State<ThinkoraApp> createState() => _ThinkoraAppState();
}

class _ThinkoraAppState extends State<ThinkoraApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  // Repositories are created once and shared across the widget tree.
  final _authRepo = AuthRepository();
  final _userRepo = UserRepository();
  final _challengeRepo = ChallengeRepository();
  final _leaderboardRepo = LeaderboardRepository();
  final _coachRepo = CoachRepository();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
    setState(() {
      _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepo),
        RepositoryProvider.value(value: _userRepo),
        RepositoryProvider.value(value: _challengeRepo),
        RepositoryProvider.value(value: _leaderboardRepo),
        RepositoryProvider.value(value: _coachRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => UserCubit(_userRepo)),
          BlocProvider(
            create: (ctx) =>
                AuthCubit(_authRepo, ctx.read<UserCubit>()),
          ),
          BlocProvider(create: (_) => LeaderboardCubit(_leaderboardRepo)),
          BlocProvider(create: (_) => CoachCubit(_coachRepo)),
        ],
        child: MaterialApp.router(
          title: 'Thinkora',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
