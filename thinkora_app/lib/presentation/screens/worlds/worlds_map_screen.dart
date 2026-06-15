import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/realm_model.dart';

class WorldsMapScreen extends StatelessWidget {
  const WorldsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final realms = RealmModel.allRealms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            expandedHeight: 0,
            title: const Text(
              'Cognitive Worlds',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Choose your realm and begin training.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  // Progress summary
                  _ProgressSummary(realms: realms),
                  const SizedBox(height: 24),
                  // Realm grid
                  ...realms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final realm = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RealmListCard(
                        realm: realm,
                        index: index,
                        currentLevel: 1,
                        completionRate: index == 0 ? 0.35 : 0.0,
                        onTap: () => context.go(
                            '${GoRouterState.of(context).matchedLocation}/realm/${realm.id}'),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final List<RealmModel> realms;

  const _ProgressSummary({required this.realms});

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
        children: [
          Expanded(
            child: _SummaryItem(
              value: '1/7',
              label: 'Realms Unlocked',
              icon: '🗺️',
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _SummaryItem(
              value: '7/20',
              label: 'Levels Done',
              icon: '⚡',
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          Expanded(
            child: _SummaryItem(
              value: '0',
              label: 'Bosses Slain',
              icon: '👑',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _SummaryItem({
    required this.value,
    required this.label,
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RealmListCard extends StatelessWidget {
  final RealmModel realm;
  final int index;
  final int currentLevel;
  final double completionRate;
  final VoidCallback onTap;

  const _RealmListCard({
    required this.realm,
    required this.index,
    required this.currentLevel,
    required this.completionRate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: realm.isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: realm.isLocked
                ? AppColors.border
                : realm.color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Realm icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: realm.isLocked
                        ? const LinearGradient(
                            colors: [AppColors.surface, AppColors.surface])
                        : realm.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: realm.isLocked
                        ? null
                        : [
                            BoxShadow(
                              color: realm.color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      realm.isLocked ? '🔒' : realm.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                          const Spacer(),
                          if (!realm.isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: realm.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Lv. $currentLevel/${realm.totalLevels}',
                                style: TextStyle(
                                  color: realm.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (realm.isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.border.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                realm.unlockRequirement,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        realm.cognitiveSkill,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!realm.isLocked) ...[
              const SizedBox(height: 14),
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
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(completionRate * 100).toInt()}%',
                    style: TextStyle(
                      color: realm.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                realm.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}
