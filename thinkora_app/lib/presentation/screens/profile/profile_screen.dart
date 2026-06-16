import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/tci_badge.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/achievement_model.dart';
import '../../blocs/user/user_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserCubit>().state.user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return _build(context, user);
  }

  Widget _build(BuildContext context, UserModel user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            expandedHeight: 0,
            title: const Text(
              'Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go(AppRoutes.achievements),
                icon: const Icon(Icons.emoji_events_outlined,
                    color: AppColors.textSecondary),
              ),
              IconButton(
                onPressed: () => context.go(AppRoutes.settings),
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _ProfileHeader(user: user),
                  const SizedBox(height: 20),
                  _TCIFullCard(rating: user.tciRating),
                  const SizedBox(height: 20),
                  _StatsGrid(stats: user.stats),
                  const SizedBox(height: 20),
                  _RecentAchievements(achievementIds: user.achievementIds),
                  const SizedBox(height: 20),
                  _ActivityHeatmap(),
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

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.displayName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.card, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '@${user.username}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          TCIBadge(score: user.tciRating.overall),
          const SizedBox(height: 16),
          // Level progress
          Row(
            children: [
              Text(
                'Level ${user.stats.level}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${user.stats.xpInCurrentLevel} / ${user.stats.xpForNextLevel} XP',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: user.stats.levelProgress.clamp(0, 1),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.xpGold),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _TCIFullCard extends StatelessWidget {
  final TCIRating rating;

  const _TCIFullCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final dimensions = [
      ('Logic', rating.logic, AppColors.logicRealm),
      ('Memory', rating.memory, AppColors.memoryRealm),
      ('Focus', rating.focus, AppColors.primary),
      ('Strategy', rating.strategy, AppColors.strategyRealm),
      ('Mathematics', rating.mathematics, AppColors.mathRealm),
      ('Creativity', rating.creativity, AppColors.creativityRealm),
      ('Problem Solving', rating.problemSolving, AppColors.innovationRealm),
      ('Learning Speed', rating.learningSpeed, AppColors.mastermindRealm),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Cognitive Dimensions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TCIBadge(
                  score: rating.overall,
                  compact: true,
                  fontSize: 12),
            ],
          ),
          const SizedBox(height: 20),
          ...dimensions.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          d.$1,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: d.$2 / 3000,
                            backgroundColor: AppColors.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(d.$3),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${d.$2}',
                          style: TextStyle(
                            color: d.$3,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
  }
}

class _StatsGrid extends StatelessWidget {
  final UserStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Challenges', '${stats.challengesCompleted}', '🎯', AppColors.logicRealm),
      ('Accuracy', '${(stats.accuracy * 100).toInt()}%', '🏹', AppColors.success),
      ('Streak', '${stats.currentStreak}d 🔥', '⚡', AppColors.streakFire),
      ('Battles Won', '${stats.battlesWon}', '⚔️', AppColors.strategyRealm),
      ('Total XP', '${stats.totalXp}', '✨', AppColors.xpGold),
      ('Time', '${stats.totalPlaytimeMinutes ~/ 60}h', '⏱️', AppColors.memoryRealm),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (item.$4 as Color).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (item.$4 as Color).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.$3, style: const TextStyle(fontSize: 20)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$2 as String,
                    style: TextStyle(
                      color: item.$4 as Color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    item.$1 as String,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 150 + index * 40))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }
}

class _RecentAchievements extends StatelessWidget {
  final List<String> achievementIds;

  const _RecentAchievements({required this.achievementIds});

  @override
  Widget build(BuildContext context) {
    final unlocked = AchievementModel.allAchievements
        .where((a) => achievementIds.contains(a.id))
        .take(6)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.achievements),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'See all',
                  style:
                      TextStyle(color: AppColors.primary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (unlocked.isEmpty)
            const Text(
              'Complete challenges to earn achievements.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: unlocked.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(a.icon,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        a.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ActivityHeatmap extends StatelessWidget {
  const _ActivityHeatmap();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity — Last 12 Weeks',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // Heatmap grid
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(84, (i) {
              // Simulate activity data
              final intensity = (i % 7 == 0 || i % 11 == 0)
                  ? 0.0
                  : (i % 3 == 0)
                      ? 1.0
                      : (i % 5 == 0)
                          ? 0.7
                          : 0.3;
              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: intensity == 0
                      ? AppColors.border
                      : AppColors.primary.withOpacity(intensity),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Less',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 10),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (i) {
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.border
                        : AppColors.primary.withOpacity(i * 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const Text(
                'More',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
