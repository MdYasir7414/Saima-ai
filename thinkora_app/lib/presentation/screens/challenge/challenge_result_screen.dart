import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/models/challenge_model.dart';

class ChallengeResultScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const ChallengeResultScreen({super.key, this.extra});

  @override
  State<ChallengeResultScreen> createState() => _ChallengeResultScreenState();
}

class _ChallengeResultScreenState extends State<ChallengeResultScreen>
    with SingleTickerProviderStateMixin {
  late final bool _isCorrect;
  late final int _xpEarned;
  late final int _tciChange;
  late final int _timeSpent;
  late final String? _explanation;
  late final ChallengeModel? _challenge;

  @override
  void initState() {
    super.initState();
    final extra = widget.extra ?? {};
    _isCorrect = extra['isCorrect'] as bool? ?? false;
    _xpEarned = extra['xpEarned'] as int? ?? 0;
    _tciChange = extra['tciChange'] as int? ?? 0;
    _timeSpent = extra['timeSpent'] as int? ?? 0;
    _explanation = extra['explanation'] as String?;
    _challenge = extra['challenge'] as ChallengeModel?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Result icon
              _ResultIcon(isCorrect: _isCorrect),
              const SizedBox(height: 24),
              // Result text
              Text(
                _isCorrect ? 'Excellent!' : 'Keep Going!',
                style: TextStyle(
                  color: _isCorrect ? AppColors.success : AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                _isCorrect
                    ? 'Your reasoning was spot-on.'
                    : 'Every mistake is a lesson. Review the explanation below.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              // Stats row
              _StatsRow(
                xpEarned: _xpEarned,
                tciChange: _tciChange,
                timeSpent: _timeSpent,
                isCorrect: _isCorrect,
              ),
              const SizedBox(height: 24),
              // Explanation
              if (_explanation != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🧠',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Explanation',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _explanation!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
              ],
              // TCI Progress
              if (_isCorrect) ...[
                _TCIProgress(tciChange: _tciChange),
                const SizedBox(height: 24),
              ],
              // Buttons
              GradientButton(
                text: 'Next Challenge',
                onPressed: () => context.go(AppRoutes.home),
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              OutlineButton(
                text: 'Back to Home',
                onPressed: () => context.go(AppRoutes.home),
              ).animate(delay: 650.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final bool isCorrect;

  const _ResultIcon({required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.12)
            : AppColors.error.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          isCorrect ? '✓' : '✗',
          style: TextStyle(
            color: isCorrect ? AppColors.success : AppColors.error,
            fontSize: 44,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms);
  }
}

class _StatsRow extends StatelessWidget {
  final int xpEarned;
  final int tciChange;
  final int timeSpent;
  final bool isCorrect;

  const _StatsRow({
    required this.xpEarned,
    required this.tciChange,
    required this.timeSpent,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '+$xpEarned',
            label: 'XP Earned',
            color: AppColors.xpGold,
            icon: '⚡',
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            value: tciChange > 0 ? '+$tciChange' : '$tciChange',
            label: 'TCI Change',
            color: tciChange >= 0 ? AppColors.success : AppColors.error,
            icon: '📈',
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(
            value: '${timeSpent}s',
            label: 'Time Used',
            color: AppColors.logicRealm,
            icon: '⏱️',
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TCIProgress extends StatelessWidget {
  final int tciChange;

  const _TCIProgress({required this.tciChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🧠', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cognitive Progress',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your cognitive rating improved by $tciChange points',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$tciChange',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
