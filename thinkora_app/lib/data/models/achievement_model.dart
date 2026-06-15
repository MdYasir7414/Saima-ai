import 'package:equatable/equatable.dart';

enum AchievementCategory {
  streak,
  challenges,
  tci,
  battles,
  social,
  exploration,
  mastery,
  speed,
}

enum AchievementRarity { common, uncommon, rare, epic, legendary }

class AchievementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xpReward;
  final Map<String, dynamic> requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.xpReward,
    required this.requirement,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progress,
  });

  String get rarityLabel {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.challenges,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      xpReward: json['xp_reward'] as int? ?? 100,
      requirement:
          json['requirement'] as Map<String, dynamic>? ?? {},
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static List<AchievementModel> get allAchievements => [
        // Streak Achievements
        AchievementModel(
          id: 'streak_3',
          title: 'On Fire',
          description: 'Maintain a 3-day streak',
          icon: '🔥',
          category: AchievementCategory.streak,
          rarity: AchievementRarity.common,
          xpReward: 100,
          requirement: {'streak_days': 3},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          icon: '⚡',
          category: AchievementCategory.streak,
          rarity: AchievementRarity.uncommon,
          xpReward: 250,
          requirement: {'streak_days': 7},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'streak_30',
          title: 'Month Master',
          description: 'Maintain a 30-day streak',
          icon: '🌟',
          category: AchievementCategory.streak,
          rarity: AchievementRarity.rare,
          xpReward: 1000,
          requirement: {'streak_days': 30},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'streak_100',
          title: 'Century Mind',
          description: 'Maintain a 100-day streak',
          icon: '💎',
          category: AchievementCategory.streak,
          rarity: AchievementRarity.legendary,
          xpReward: 5000,
          requirement: {'streak_days': 100},
          isUnlocked: false,
          progress: 0,
        ),
        // Challenge Achievements
        AchievementModel(
          id: 'challenges_10',
          title: 'First Steps',
          description: 'Complete 10 challenges',
          icon: '🎯',
          category: AchievementCategory.challenges,
          rarity: AchievementRarity.common,
          xpReward: 150,
          requirement: {'challenges_completed': 10},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'challenges_100',
          title: 'Challenge Seeker',
          description: 'Complete 100 challenges',
          icon: '🏆',
          category: AchievementCategory.challenges,
          rarity: AchievementRarity.uncommon,
          xpReward: 500,
          requirement: {'challenges_completed': 100},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'challenges_1000',
          title: 'Challenge Titan',
          description: 'Complete 1000 challenges',
          icon: '👑',
          category: AchievementCategory.challenges,
          rarity: AchievementRarity.epic,
          xpReward: 5000,
          requirement: {'challenges_completed': 1000},
          isUnlocked: false,
          progress: 0,
        ),
        // TCI Achievements
        AchievementModel(
          id: 'tci_1200',
          title: 'Intermediate Mind',
          description: 'Reach TCI 1200',
          icon: '🧠',
          category: AchievementCategory.tci,
          rarity: AchievementRarity.uncommon,
          xpReward: 500,
          requirement: {'tci_overall': 1200},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'tci_2000',
          title: 'Advanced Thinker',
          description: 'Reach TCI 2000',
          icon: '⚡',
          category: AchievementCategory.tci,
          rarity: AchievementRarity.rare,
          xpReward: 2000,
          requirement: {'tci_overall': 2000},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'tci_3000',
          title: 'Grandmaster',
          description: 'Reach TCI 3000 — the elite tier',
          icon: '🌌',
          category: AchievementCategory.tci,
          rarity: AchievementRarity.legendary,
          xpReward: 10000,
          requirement: {'tci_overall': 3000},
          isUnlocked: false,
          progress: 0,
        ),
        // Battle Achievements
        AchievementModel(
          id: 'battles_1',
          title: 'First Blood',
          description: 'Win your first Brain Battle',
          icon: '⚔️',
          category: AchievementCategory.battles,
          rarity: AchievementRarity.common,
          xpReward: 200,
          requirement: {'battles_won': 1},
          isUnlocked: false,
          progress: 0,
        ),
        AchievementModel(
          id: 'battles_50',
          title: 'Battle Hardened',
          description: 'Win 50 Brain Battles',
          icon: '🛡️',
          category: AchievementCategory.battles,
          rarity: AchievementRarity.epic,
          xpReward: 3000,
          requirement: {'battles_won': 50},
          isUnlocked: false,
          progress: 0,
        ),
        // Social Achievements
        AchievementModel(
          id: 'friends_5',
          title: 'Social Thinker',
          description: 'Add 5 friends',
          icon: '🤝',
          category: AchievementCategory.social,
          rarity: AchievementRarity.common,
          xpReward: 100,
          requirement: {'friends_count': 5},
          isUnlocked: false,
          progress: 0,
        ),
        // Speed Achievements
        AchievementModel(
          id: 'speed_master',
          title: 'Speed Demon',
          description: 'Complete a challenge in under 10 seconds',
          icon: '💨',
          category: AchievementCategory.speed,
          rarity: AchievementRarity.rare,
          xpReward: 750,
          requirement: {'challenge_time_seconds': 10},
          isUnlocked: false,
          progress: 0,
        ),
        // Exploration Achievements
        AchievementModel(
          id: 'all_realms',
          title: 'World Explorer',
          description: 'Complete at least one level in every realm',
          icon: '🗺️',
          category: AchievementCategory.exploration,
          rarity: AchievementRarity.epic,
          xpReward: 2500,
          requirement: {'realms_explored': 7},
          isUnlocked: false,
          progress: 0,
        ),
        // Mastery Achievements
        AchievementModel(
          id: 'realm_mastery',
          title: 'Realm Conqueror',
          description: 'Complete all levels in any realm',
          icon: '🏰',
          category: AchievementCategory.mastery,
          rarity: AchievementRarity.legendary,
          xpReward: 7500,
          requirement: {'realm_completed': 1},
          isUnlocked: false,
          progress: 0,
        ),
      ];

  @override
  List<Object?> get props =>
      [id, isUnlocked, progress, unlockedAt];
}
