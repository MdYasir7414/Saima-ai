class AppConstants {
  static const String appName = 'Thinkora';
  static const String appTagline = 'Master the Art of Thinking';

  // API
  static const String baseUrl = 'https://api.thinkora.ai/v1';
  static const int apiTimeout = 30000;

  // TCI Thresholds
  static const int tciBeginner = 500;
  static const int tciIntermediate = 1200;
  static const int tciAdvanced = 2000;
  static const int tciExpert = 2500;
  static const int tciMaster = 2800;
  static const int tciGrandmaster = 3000;

  // XP per action
  static const int xpChallengeBeginner = 15;
  static const int xpChallengeIntermediate = 30;
  static const int xpChallengeAdvanced = 60;
  static const int xpChallengeExpert = 100;
  static const int xpDailyQuest = 50;
  static const int xpStreakBonus = 20;
  static const int xpBattleWin = 75;
  static const int xpBattleLoss = 10;
  static const int xpBossDefeat = 200;

  // Streak
  static const int streakSaverHours = 12;

  // Daily Quest
  static const int dailyQuestMinutes = 15;
  static const int dailyQuestChallengeCount = 5;

  // Realms
  static const List<String> realmIds = [
    'logic',
    'strategy',
    'memory',
    'math',
    'creativity',
    'innovation',
    'mastermind',
  ];

  static const List<String> realmNames = [
    'Logic Realm',
    'Strategy Realm',
    'Memory Realm',
    'Math Realm',
    'Creativity Realm',
    'Innovation Realm',
    'Mastermind Realm',
  ];

  // Age Groups
  static const Map<String, List<int>> ageGroups = {
    'explorer': [3, 5],
    'adventurer': [6, 9],
    'scholar': [10, 13],
    'challenger': [14, 17],
    'pioneer': [18, 99],
  };

  // Challenge Types
  static const List<String> challengeTypes = [
    'logic_puzzle',
    'pattern_recognition',
    'memory_sequence',
    'math_reasoning',
    'spatial_reasoning',
    'verbal_reasoning',
    'decision_simulation',
    'strategy_puzzle',
    'creativity_challenge',
    'word_association',
  ];

  // Cognitive Dimensions
  static const List<String> cognitiveDimensions = [
    'logic',
    'memory',
    'focus',
    'strategy',
    'mathematics',
    'creativity',
    'problem_solving',
    'learning_speed',
  ];

  // Leaderboard Scopes
  static const List<String> leaderboardScopes = [
    'global',
    'country',
    'age_group',
    'weekly',
    'monthly',
  ];

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 1000);

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String challengeCacheBox = 'challenge_cache';
  static const String progressBox = 'progress_box';

  // SharedPrefs Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedAge = 'selected_age';
  static const String keyNotifications = 'notifications_enabled';
  static const String keySoundEffects = 'sound_effects_enabled';
}

class AgeGroup {
  final String id;
  final String name;
  final int minAge;
  final int maxAge;
  final String description;

  const AgeGroup({
    required this.id,
    required this.name,
    required this.minAge,
    required this.maxAge,
    required this.description,
  });

  static const List<AgeGroup> all = [
    AgeGroup(
      id: 'explorer',
      name: 'Little Explorer',
      minAge: 3,
      maxAge: 5,
      description: 'Ages 3–5',
    ),
    AgeGroup(
      id: 'adventurer',
      name: 'Young Adventurer',
      minAge: 6,
      maxAge: 9,
      description: 'Ages 6–9',
    ),
    AgeGroup(
      id: 'scholar',
      name: 'Junior Scholar',
      minAge: 10,
      maxAge: 13,
      description: 'Ages 10–13',
    ),
    AgeGroup(
      id: 'challenger',
      name: 'Rising Challenger',
      minAge: 14,
      maxAge: 17,
      description: 'Ages 14–17',
    ),
    AgeGroup(
      id: 'pioneer',
      name: 'Cognitive Pioneer',
      minAge: 18,
      maxAge: 99,
      description: 'Ages 18+',
    ),
  ];
}
