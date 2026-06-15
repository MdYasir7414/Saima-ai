import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _dailyReminder = true;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress is saved. You can sign back in anytime.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyAuthToken);
      if (!mounted) return;
      context.go(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _SectionHeader(title: 'Account'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: '@thinkmaster',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.family_restroom,
              title: 'Parent Dashboard',
              subtitle: 'Monitor child progress',
              onTap: () => context.go(AppRoutes.parentDashboard),
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Country',
              subtitle: '🇺🇸 United States',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // Appearance
            _SectionHeader(title: 'Appearance'),
            _ToggleTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (v) => setState(() => _darkMode = v),
            ),
            const SizedBox(height: 24),

            // Notifications
            _SectionHeader(title: 'Notifications'),
            _ToggleTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _ToggleTile(
              icon: Icons.alarm_outlined,
              title: 'Daily Reminder',
              value: _dailyReminder,
              onChanged: (v) => setState(() => _dailyReminder = v),
            ),
            const SizedBox(height: 24),

            // Audio
            _SectionHeader(title: 'Audio'),
            _ToggleTile(
              icon: Icons.volume_up_outlined,
              title: 'Sound Effects',
              value: _soundEffects,
              onChanged: (v) => setState(() => _soundEffects = v),
            ),
            const SizedBox(height: 24),

            // Cognitive settings
            _SectionHeader(title: 'Training'),
            _SettingsTile(
              icon: Icons.tune,
              title: 'Age Group',
              subtitle: 'Cognitive Pioneer (18+)',
              onTap: () => context.go(AppRoutes.ageSelection),
            ),
            _SettingsTile(
              icon: Icons.analytics_outlined,
              title: 'Reset TCI Rating',
              subtitle: 'Start fresh from TCI 500',
              onTap: () {},
              isDestructive: true,
            ),
            const SizedBox(height: 24),

            // Support
            _SectionHeader(title: 'Support'),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: 'Thinkora v1.0.0',
              onTap: null,
            ),
            const SizedBox(height: 24),

            // Sign out
            GestureDetector(
              onTap: _signOut,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.error.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
