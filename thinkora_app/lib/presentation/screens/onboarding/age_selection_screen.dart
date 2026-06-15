import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/gradient_button.dart';

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  String? _selectedAgeGroupId;

  Future<void> _continue() async {
    if (_selectedAgeGroupId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedAge, _selectedAgeGroupId!);
    await prefs.setBool(AppConstants.keyOnboardingComplete, true);

    if (!mounted) return;
    context.go(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              const Text(
                'Who is this for?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text(
                'We\'ll adapt the experience to your age group.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 36),
              // Age groups
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AgeGroup.all.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final group = AgeGroup.all[index];
                    final isSelected = _selectedAgeGroupId == group.id;
                    return _AgeGroupCard(
                      group: group,
                      isSelected: isSelected,
                      onTap: () =>
                          setState(() => _selectedAgeGroupId = group.id),
                      index: index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Continue',
                onPressed: _selectedAgeGroupId != null ? _continue : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeGroupCard extends StatelessWidget {
  final AgeGroup group;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _AgeGroupCard({
    required this.group,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  static const Map<String, String> _icons = {
    'explorer': '🌟',
    'adventurer': '🚀',
    'scholar': '📚',
    'challenger': '⚡',
    'pioneer': '🧠',
  };

  static const Map<String, String> _descriptions = {
    'explorer': 'Fun puzzles, shapes, and colors',
    'adventurer': 'Stories, logic, and number games',
    'scholar': 'Critical thinking and problem-solving',
    'challenger': 'Advanced reasoning and strategy',
    'pioneer': 'Elite cognitive training',
  };

  static const Map<String, Color> _colors = {
    'explorer': AppColors.mathRealm,
    'adventurer': AppColors.innovationRealm,
    'scholar': AppColors.logicRealm,
    'challenger': AppColors.strategyRealm,
    'pioneer': AppColors.mastermindRealm,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[group.id] ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              _icons[group.id] ?? '🎯',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    group.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _descriptions[group.id] ?? '',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.1, end: 0, duration: 400.ms),
    );
  }
}
