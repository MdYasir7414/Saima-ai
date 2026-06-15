import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

class ThinkoraApp extends StatefulWidget {
  const ThinkoraApp({super.key});

  @override
  State<ThinkoraApp> createState() => _ThinkoraAppState();
}

class _ThinkoraAppState extends State<ThinkoraApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(AppConstants.keyThemeMode) ?? 'dark';
    setState(() {
      _themeMode =
          savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Thinkora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: appRouter,
    );
  }
}
