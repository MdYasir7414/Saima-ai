import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/leaderboard_model.dart';

/// Loads ranked leaderboards with a generated fallback dataset so the
/// rankings screen always has content to display.
class LeaderboardRepository {
  LeaderboardRepository({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<LeaderboardData> fetch({
    String scope = 'global',
    String? ageGroup,
    String? country,
  }) async {
    try {
      final res = await _client.get('/leaderboard', queryParameters: {
        'scope': scope,
        if (ageGroup != null) 'ageGroup': ageGroup,
        if (country != null) 'country': country,
      });
      return LeaderboardData.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _demoData(scope);
      throw ApiException.fromDio(e);
    }
  }

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown ||
        (e.response?.statusCode ?? 0) >= 500;
  }

  LeaderboardData _demoData(String scope) {
    const names = [
      'NeuralStrike', 'LogicMaster', 'ThinkTitan', 'BrainWave', 'CogEdge',
      'MindForge', 'IQBlast', 'StratosX', 'PuzzleKing', 'ReasonBot',
    ];
    const countries = ['US', 'IN', 'GB', 'DE', 'JP', 'KR', 'BR', 'CA', 'AU', 'FR'];

    final entries = List.generate(50, (i) {
      return LeaderboardEntry(
        rank: i + 1,
        userId: 'u$i',
        username: '${names[i % names.length]}${i + 1}',
        displayName: '${names[i % names.length]} ${i + 1}',
        country: countries[i % countries.length],
        tciOverall: 3200 - (i * 42),
        tciTier: i < 3 ? 'Grandmaster' : i < 10 ? 'Master' : 'Expert',
        weeklyXp: 8500 - (i * 120),
        currentStreak: 45 - i,
        challengesCompleted: 1200 - (i * 18),
        isCurrentUser: i == 12,
      );
    });

    return LeaderboardData(
      scope: scope,
      entries: entries,
      currentUserEntry: entries[12],
      lastUpdated: DateTime.now(),
    );
  }
}
