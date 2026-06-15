import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String displayName;
  final int age;
  final String ageGroup;
  final String country;
  final TCIRating tciRating;
  final UserStats stats;
  final UserProgress progress;
  final List<String> achievementIds;
  final List<String> friendIds;
  final bool isParentAccount;
  final String? parentId;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.displayName,
    required this.age,
    required this.ageGroup,
    required this.country,
    required this.tciRating,
    required this.stats,
    required this.progress,
    required this.achievementIds,
    required this.friendIds,
    required this.isParentAccount,
    this.parentId,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      displayName: json['display_name'] as String,
      age: json['age'] as int,
      ageGroup: json['age_group'] as String,
      country: json['country'] as String? ?? 'Unknown',
      tciRating: TCIRating.fromJson(json['tci_rating'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      progress:
          UserProgress.fromJson(json['progress'] as Map<String, dynamic>),
      achievementIds: List<String>.from(json['achievement_ids'] as List),
      friendIds: List<String>.from(json['friend_ids'] as List),
      isParentAccount: json['is_parent_account'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'display_name': displayName,
      'age': age,
      'age_group': ageGroup,
      'country': country,
      'tci_rating': tciRating.toJson(),
      'stats': stats.toJson(),
      'progress': progress.toJson(),
      'achievement_ids': achievementIds,
      'friend_ids': friendIds,
      'is_parent_account': isParentAccount,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? displayName,
    int? age,
    String? ageGroup,
    String? country,
    TCIRating? tciRating,
    UserStats? stats,
    UserProgress? progress,
    List<String>? achievementIds,
    List<String>? friendIds,
    bool? isParentAccount,
    String? parentId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      ageGroup: ageGroup ?? this.ageGroup,
      country: country ?? this.country,
      tciRating: tciRating ?? this.tciRating,
      stats: stats ?? this.stats,
      progress: progress ?? this.progress,
      achievementIds: achievementIds ?? this.achievementIds,
      friendIds: friendIds ?? this.friendIds,
      isParentAccount: isParentAccount ?? this.isParentAccount,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        tciRating,
        stats,
        progress,
      ];
}

class TCIRating extends Equatable {
  final int overall;
  final int logic;
  final int memory;
  final int focus;
  final int strategy;
  final int mathematics;
  final int creativity;
  final int problemSolving;
  final int learningSpeed;

  const TCIRating({
    required this.overall,
    required this.logic,
    required this.memory,
    required this.focus,
    required this.strategy,
    required this.mathematics,
    required this.creativity,
    required this.problemSolving,
    required this.learningSpeed,
  });

  factory TCIRating.initial() => const TCIRating(
        overall: 500,
        logic: 500,
        memory: 500,
        focus: 500,
        strategy: 500,
        mathematics: 500,
        creativity: 500,
        problemSolving: 500,
        learningSpeed: 500,
      );

  factory TCIRating.fromJson(Map<String, dynamic> json) {
    return TCIRating(
      overall: json['overall'] as int? ?? 500,
      logic: json['logic'] as int? ?? 500,
      memory: json['memory'] as int? ?? 500,
      focus: json['focus'] as int? ?? 500,
      strategy: json['strategy'] as int? ?? 500,
      mathematics: json['mathematics'] as int? ?? 500,
      creativity: json['creativity'] as int? ?? 500,
      problemSolving: json['problem_solving'] as int? ?? 500,
      learningSpeed: json['learning_speed'] as int? ?? 500,
    );
  }

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'logic': logic,
        'memory': memory,
        'focus': focus,
        'strategy': strategy,
        'mathematics': mathematics,
        'creativity': creativity,
        'problem_solving': problemSolving,
        'learning_speed': learningSpeed,
      };

  String get tier {
    if (overall >= 3000) return 'Grandmaster';
    if (overall >= 2800) return 'Master';
    if (overall >= 2500) return 'Expert';
    if (overall >= 2000) return 'Advanced';
    if (overall >= 1200) return 'Intermediate';
    return 'Beginner';
  }

  @override
  List<Object> get props => [
        overall,
        logic,
        memory,
        focus,
        strategy,
        mathematics,
        creativity,
        problemSolving,
        learningSpeed
      ];
}

class UserStats extends Equatable {
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int challengesCompleted;
  final int challengesAttempted;
  final int battlesWon;
  final int battlesLost;
  final int totalPlaytimeMinutes;
  final DateTime? lastCompletedAt;

  const UserStats({
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.challengesCompleted,
    required this.challengesAttempted,
    required this.battlesWon,
    required this.battlesLost,
    required this.totalPlaytimeMinutes,
    this.lastCompletedAt,
  });

  factory UserStats.initial() => const UserStats(
        totalXp: 0,
        level: 1,
        currentStreak: 0,
        longestStreak: 0,
        challengesCompleted: 0,
        challengesAttempted: 0,
        battlesWon: 0,
        battlesLost: 0,
        totalPlaytimeMinutes: 0,
      );

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      challengesCompleted: json['challenges_completed'] as int? ?? 0,
      challengesAttempted: json['challenges_attempted'] as int? ?? 0,
      battlesWon: json['battles_won'] as int? ?? 0,
      battlesLost: json['battles_lost'] as int? ?? 0,
      totalPlaytimeMinutes: json['total_playtime_minutes'] as int? ?? 0,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_xp': totalXp,
        'level': level,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'challenges_completed': challengesCompleted,
        'challenges_attempted': challengesAttempted,
        'battles_won': battlesWon,
        'battles_lost': battlesLost,
        'total_playtime_minutes': totalPlaytimeMinutes,
        'last_completed_at': lastCompletedAt?.toIso8601String(),
      };

  double get accuracy => challengesAttempted == 0
      ? 0
      : challengesCompleted / challengesAttempted;

  int get xpForNextLevel => (level * 1000);
  int get xpInCurrentLevel => totalXp - _xpForLevel(level - 1);
  double get levelProgress =>
      xpInCurrentLevel / (xpForNextLevel - _xpForLevel(level - 1));

  int _xpForLevel(int lvl) => lvl <= 0 ? 0 : lvl * 1000;

  @override
  List<Object?> get props => [totalXp, level, currentStreak, challengesCompleted];
}

class UserProgress extends Equatable {
  final Map<String, RealmProgress> realmProgress;
  final List<String> completedDailyQuests;
  final bool dailyQuestCompletedToday;

  const UserProgress({
    required this.realmProgress,
    required this.completedDailyQuests,
    required this.dailyQuestCompletedToday,
  });

  factory UserProgress.initial() => const UserProgress(
        realmProgress: {},
        completedDailyQuests: [],
        dailyQuestCompletedToday: false,
      );

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final realmProgressMap = <String, RealmProgress>{};
    final rpJson = json['realm_progress'] as Map<String, dynamic>? ?? {};
    rpJson.forEach((key, value) {
      realmProgressMap[key] =
          RealmProgress.fromJson(value as Map<String, dynamic>);
    });

    return UserProgress(
      realmProgress: realmProgressMap,
      completedDailyQuests:
          List<String>.from(json['completed_daily_quests'] as List? ?? []),
      dailyQuestCompletedToday:
          json['daily_quest_completed_today'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'realm_progress':
            realmProgress.map((k, v) => MapEntry(k, v.toJson())),
        'completed_daily_quests': completedDailyQuests,
        'daily_quest_completed_today': dailyQuestCompletedToday,
      };

  @override
  List<Object> get props => [realmProgress, completedDailyQuests];
}

class RealmProgress extends Equatable {
  final String realmId;
  final int currentLevel;
  final int totalLevels;
  final bool bossDefeated;
  final int starsEarned;

  const RealmProgress({
    required this.realmId,
    required this.currentLevel,
    required this.totalLevels,
    required this.bossDefeated,
    required this.starsEarned,
  });

  factory RealmProgress.fromJson(Map<String, dynamic> json) {
    return RealmProgress(
      realmId: json['realm_id'] as String,
      currentLevel: json['current_level'] as int? ?? 1,
      totalLevels: json['total_levels'] as int? ?? 20,
      bossDefeated: json['boss_defeated'] as bool? ?? false,
      starsEarned: json['stars_earned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'realm_id': realmId,
        'current_level': currentLevel,
        'total_levels': totalLevels,
        'boss_defeated': bossDefeated,
        'stars_earned': starsEarned,
      };

  double get completionRate => currentLevel / totalLevels;

  @override
  List<Object> get props =>
      [realmId, currentLevel, totalLevels, bossDefeated, starsEarned];
}
