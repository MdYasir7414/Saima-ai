import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TCIBadge extends StatelessWidget {
  final int score;
  final double fontSize;
  final bool showTier;
  final bool compact;

  const TCIBadge({
    super.key,
    required this.score,
    this.fontSize = 14,
    this.showTier = true,
    this.compact = false,
  });

  Color get _tierColor {
    if (score >= 3000) return AppColors.tciGrandmaster;
    if (score >= 2800) return AppColors.tciMaster;
    if (score >= 2500) return AppColors.tciExpert;
    if (score >= 2000) return AppColors.tciAdvanced;
    if (score >= 1200) return AppColors.tciIntermediate;
    return AppColors.tciBeginner;
  }

  String get _tierLabel {
    if (score >= 3000) return 'Grandmaster';
    if (score >= 2800) return 'Master';
    if (score >= 2500) return 'Expert';
    if (score >= 2000) return 'Advanced';
    if (score >= 1200) return 'Intermediate';
    return 'Beginner';
  }

  String get _tierIcon {
    if (score >= 3000) return '👑';
    if (score >= 2800) return '💜';
    if (score >= 2500) return '💎';
    if (score >= 2000) return '⚡';
    if (score >= 1200) return '🔷';
    return '🔰';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _tierColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _tierColor.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Text(
          'TCI $score',
          style: TextStyle(
            color: _tierColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _tierColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tierColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_tierIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'TCI $score',
                style: TextStyle(
                  color: _tierColor,
                  fontSize: fontSize + 2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (showTier) ...[
            const SizedBox(height: 2),
            Text(
              _tierLabel,
              style: TextStyle(
                color: _tierColor.withOpacity(0.8),
                fontSize: fontSize - 2,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TCIProgressRing extends StatelessWidget {
  final int currentScore;
  final double size;

  const TCIProgressRing({
    super.key,
    required this.currentScore,
    this.size = 120,
  });

  Color get _tierColor {
    if (currentScore >= 3000) return AppColors.tciGrandmaster;
    if (currentScore >= 2800) return AppColors.tciMaster;
    if (currentScore >= 2500) return AppColors.tciExpert;
    if (currentScore >= 2000) return AppColors.tciAdvanced;
    if (currentScore >= 1200) return AppColors.tciIntermediate;
    return AppColors.tciBeginner;
  }

  int get _nextThreshold {
    if (currentScore >= 3000) return 3500;
    if (currentScore >= 2800) return 3000;
    if (currentScore >= 2500) return 2800;
    if (currentScore >= 2000) return 2500;
    if (currentScore >= 1200) return 2000;
    return 1200;
  }

  int get _prevThreshold {
    if (currentScore >= 3000) return 2800;
    if (currentScore >= 2800) return 2500;
    if (currentScore >= 2500) return 2000;
    if (currentScore >= 2000) return 1200;
    if (currentScore >= 1200) return 500;
    return 0;
  }

  double get _progress {
    final range = _nextThreshold - _prevThreshold;
    final current = currentScore - _prevThreshold;
    return (current / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_tierColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentScore',
                style: TextStyle(
                  color: _tierColor,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'TCI',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
