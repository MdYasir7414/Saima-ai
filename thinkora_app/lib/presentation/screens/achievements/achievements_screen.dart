import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/achievement_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _unlockedIds = const [
    'streak_3',
    'challenges_10',
    'battles_1',
    'streak_7',
    'challenges_100',
  ];

  static const List<String> _categories = [
    'All',
    'Streak',
    'Challenges',
    'TCI',
    'Battles',
    'Social',
  ];

  int _selectedCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedCategory = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AchievementModel> get _filteredAchievements {
    final all = AchievementModel.allAchievements.map((a) {
      return AchievementModel(
        id: a.id,
        title: a.title,
        description: a.description,
        icon: a.icon,
        category: a.category,
        rarity: a.rarity,
        xpReward: a.xpReward,
        requirement: a.requirement,
        isUnlocked: _unlockedIds.contains(a.id),
        unlockedAt: _unlockedIds.contains(a.id) ? DateTime.now() : null,
        progress: _unlockedIds.contains(a.id)
            ? 1.0
            : _getProgress(a),
      );
    }).toList();

    if (_selectedCategory == 0) return all;

    final categoryMap = {
      1: AchievementCategory.streak,
      2: AchievementCategory.challenges,
      3: AchievementCategory.tci,
      4: AchievementCategory.battles,
      5: AchievementCategory.social,
    };

    return all
        .where((a) => a.category == categoryMap[_selectedCategory])
        .toList();
  }

  double _getProgress(AchievementModel a) {
    if (a.id.contains('streak')) return 0.7;
    if (a.id.contains('challenges')) return 0.342;
    if (a.id.contains('tci')) return 0.5;
    if (a.id.contains('battles')) return 0.28;
    return 0.1;
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _filteredAchievements;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              tabs: _categories.map((c) => Tab(text: c)).toList(),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Progress banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.xpGold.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.xpGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆',
                            style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$unlockedCount / ${achievements.length} Unlocked',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: achievements.isEmpty
                                      ? 0
                                      : unlockedCount / achievements.length,
                                  backgroundColor: AppColors.border,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.xpGold),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _AchievementCard(
                  achievement: achievements[index],
                  index: index,
                ),
                childCount: achievements.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.index,
  });

  Color get _rarityColor {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return AppColors.tciBeginner;
      case AchievementRarity.uncommon:
        return AppColors.tciIntermediate;
      case AchievementRarity.rare:
        return AppColors.tciAdvanced;
      case AchievementRarity.epic:
        return AppColors.tciMaster;
      case AchievementRarity.legendary:
        return AppColors.tciGrandmaster;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? _rarityColor.withOpacity(0.06)
            : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.isUnlocked
              ? _rarityColor.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? _rarityColor.withOpacity(0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: achievement.isUnlocked
                    ? _rarityColor.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                achievement.isUnlocked ? achievement.icon : '🔒',
                style: TextStyle(
                  fontSize: 24,
                  color: achievement.isUnlocked
                      ? null
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          color: achievement.isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _rarityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        achievement.rarityLabel,
                        style: TextStyle(
                          color: _rarityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (!achievement.isUnlocked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: achievement.progress,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _rarityColor.withOpacity(0.6)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(achievement.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: _rarityColor.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievement.isUnlocked)
                  Row(
                    children: [
                      const Text('✅',
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked · +${achievement.xpReward} XP',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0);
  }
}
