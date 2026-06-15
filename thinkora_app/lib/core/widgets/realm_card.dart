import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/realm_model.dart';
import '../constants/app_colors.dart';

class RealmCard extends StatelessWidget {
  final RealmModel realm;
  final int currentLevel;
  final double completionRate;
  final VoidCallback onTap;
  final int index;

  const RealmCard({
    super.key,
    required this.realm,
    required this.currentLevel,
    required this.completionRate,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: realm.isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: realm.isLocked
                ? AppColors.border
                : realm.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: realm.isLocked
              ? null
              : [
                  BoxShadow(
                    color: realm.color.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Background glow
            if (!realm.isLocked)
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: realm.color.withOpacity(0.06),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: realm.isLocked
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.border,
                                    AppColors.border
                                  ],
                                )
                              : realm.gradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            realm.isLocked ? '🔒' : realm.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!realm.isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: realm.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Lv. $currentLevel',
                            style: TextStyle(
                              color: realm.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (realm.isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.border.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            realm.unlockRequirement,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    realm.name,
                    style: TextStyle(
                      color: realm.isLocked
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    realm.cognitiveSkill,
                    style: TextStyle(
                      color: realm.isLocked
                          ? AppColors.textDisabled
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!realm.isLocked) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completionRate,
                              backgroundColor: AppColors.border,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(realm.color),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: TextStyle(
                            color: realm.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (realm.isLocked) ...[
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class CompactRealmCard extends StatelessWidget {
  final RealmModel realm;
  final VoidCallback onTap;

  const CompactRealmCard({
    super.key,
    required this.realm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: realm.isLocked ? null : onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: realm.isLocked
                ? AppColors.border
                : realm.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: realm.isLocked
                    ? const LinearGradient(
                        colors: [AppColors.border, AppColors.border])
                    : realm.gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  realm.isLocked ? '🔒' : realm.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              realm.name.split(' ').first,
              style: TextStyle(
                color: realm.isLocked
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
