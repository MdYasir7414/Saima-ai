import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Reads and updates the current user's profile, TCI, and stats.
class UserRepository {
  UserRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;
  UserModel? _cached;

  /// Applies the result of a graded challenge to the in-memory user so the
  /// UI reflects progress immediately even without a round-trip.
  UserModel applyProgress({
    required UserModel user,
    required bool isCorrect,
    required int xpEarned,
    required int tciChange,
    required Map<String, int> dimensionChanges,
  }) {
    final r = user.tciRating;
    int dim(String key, int current) =>
        (current + (dimensionChanges[key] ?? 0)).clamp(100, 9999);

    final updated = user.copyWith(
      tciRating: TCIRating(
        overall: (r.overall + tciChange).clamp(100, 9999),
        logic: dim('logic', r.logic),
        memory: dim('memory', r.memory),
        focus: dim('focus', r.focus),
        strategy: dim('strategy', r.strategy),
        mathematics: dim('mathematics', r.mathematics),
        creativity: dim('creativity', r.creativity),
        problemSolving: dim('problem_solving', r.problemSolving),
        learningSpeed: dim('learning_speed', r.learningSpeed),
      ),
      stats: UserStats(
        totalXp: user.stats.totalXp + xpEarned,
        level: _levelForXp(user.stats.totalXp + xpEarned),
        currentStreak: user.stats.currentStreak,
        longestStreak: user.stats.longestStreak,
        challengesCompleted:
            user.stats.challengesCompleted + (isCorrect ? 1 : 0),
        challengesAttempted: user.stats.challengesAttempted + 1,
        battlesWon: user.stats.battlesWon,
        battlesLost: user.stats.battlesLost,
        totalPlaytimeMinutes: user.stats.totalPlaytimeMinutes,
        lastCompletedAt: DateTime.now(),
      ),
    );
    _cached = updated;
    return updated;
  }

  int _levelForXp(int xp) => (xp / 1000).floor() + 1;

  Future<UserModel?> getMe() async {
    try {
      final res = await _client.get('/users/me');
      final data = res.data as Map<String, dynamic>;
      final user = _fromMeJson(data);
      _cached = user;
      return user;
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _cached ?? _demoUser();
      throw ApiException.fromDio(e);
    }
  }

  /// Last-resort profile used when there is no cached user and the backend
  /// cannot be reached (e.g. a cold launch with a saved token but no network).
  UserModel _demoUser() {
    final user = UserModel(
      id: 'u_demo',
      username: 'thinkmaster',
      email: 'user@thinkora.ai',
      displayName: 'Think Master',
      age: 22,
      ageGroup: 'pioneer',
      country: 'US',
      tciRating: const TCIRating(
        overall: 1547,
        logic: 1620,
        memory: 1480,
        focus: 1590,
        strategy: 1510,
        mathematics: 1650,
        creativity: 1390,
        problemSolving: 1560,
        learningSpeed: 1470,
      ),
      stats: UserStats(
        totalXp: 12450,
        level: 13,
        currentStreak: 7,
        longestStreak: 21,
        challengesCompleted: 342,
        challengesAttempted: 398,
        battlesWon: 28,
        battlesLost: 14,
        totalPlaytimeMinutes: 1820,
        lastCompletedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      progress: UserProgress.initial(),
      achievementIds: const ['streak_7', 'challenges_100', 'battles_1'],
      friendIds: const [],
      isParentAccount: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastActiveAt: DateTime.now(),
    );
    _cached = user;
    return user;
  }

  Future<void> updateProfile({
    String? displayName,
    String? country,
    String? avatarUrl,
  }) async {
    try {
      await _client.patch('/users/me', data: {
        if (displayName != null) 'displayName': displayName,
        if (country != null) 'country': country,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
    } on DioException catch (e) {
      if (!_isNetworkFailure(e)) throw ApiException.fromDio(e);
    }
  }

  void cache(UserModel user) => _cached = user;
  UserModel? get cached => _cached;

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown ||
        (e.response?.statusCode ?? 0) >= 500;
  }

  UserModel _fromMeJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'] as String,
      username: j['username'] as String? ?? 'thinker',
      email: j['email'] as String? ?? '',
      avatarUrl: j['avatar_url'] as String?,
      displayName: j['display_name'] as String? ?? 'Thinker',
      age: j['age'] as int? ?? 18,
      ageGroup: j['age_group'] as String? ?? 'pioneer',
      country: j['country'] as String? ?? 'Unknown',
      tciRating: TCIRating(
        overall: j['overall'] as int? ?? 500,
        logic: j['logic'] as int? ?? 500,
        memory: j['memory'] as int? ?? 500,
        focus: j['focus'] as int? ?? 500,
        strategy: j['strategy'] as int? ?? 500,
        mathematics: j['mathematics'] as int? ?? 500,
        creativity: j['creativity'] as int? ?? 500,
        problemSolving: j['problem_solving'] as int? ?? 500,
        learningSpeed: j['learning_speed'] as int? ?? 500,
      ),
      stats: UserStats(
        totalXp: j['total_xp'] as int? ?? 0,
        level: j['level'] as int? ?? 1,
        currentStreak: j['current_streak'] as int? ?? 0,
        longestStreak: j['longest_streak'] as int? ?? 0,
        challengesCompleted: j['challenges_completed'] as int? ?? 0,
        challengesAttempted: j['challenges_attempted'] as int? ?? 0,
        battlesWon: j['battles_won'] as int? ?? 0,
        battlesLost: j['battles_lost'] as int? ?? 0,
        totalPlaytimeMinutes: j['total_playtime_minutes'] as int? ?? 0,
      ),
      progress: UserProgress.initial(),
      achievementIds: const [],
      friendIds: const [],
      isParentAccount: j['is_parent_account'] as bool? ?? false,
      createdAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'] as String)
          : DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }
}
