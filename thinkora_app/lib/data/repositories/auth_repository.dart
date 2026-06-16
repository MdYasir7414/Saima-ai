import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthResult {
  AuthResult({required this.user, required this.token});
  final UserModel user;
  final String token;
}

/// Handles authentication against the backend with a local demo fallback so
/// the app remains usable when no server is configured.
class AuthRepository {
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return _persist(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _demoLogin(email);
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required int age,
    required String ageGroup,
    String country = 'Unknown',
  }) async {
    try {
      final res = await _client.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'age': age,
        'ageGroup': ageGroup,
        'country': country,
      });
      return _persist(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _demoLogin(email, username: username);
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthResult> googleSignIn({
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      final res = await _client.post('/auth/google', data: {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      });
      return _persist(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _demoLogin(email, username: displayName);
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove('refresh_token');
    await prefs.remove(AppConstants.keyUserId);
  }

  Future<AuthResult> _persist(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = data['accessToken'] as String? ?? 'session_token';
    final refresh = data['refreshToken'] as String?;
    await prefs.setString(AppConstants.keyAuthToken, token);
    if (refresh != null) await prefs.setString('refresh_token', refresh);

    final userJson = data['user'] as Map<String, dynamic>?;
    final user = userJson != null
        ? _userFromAuthJson(userJson)
        : _demoUser('user@thinkora.ai');
    await prefs.setString(AppConstants.keyUserId, user.id);
    return AuthResult(user: user, token: token);
  }

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
  }

  Future<AuthResult> _demoLogin(String email, {String? username}) async {
    final prefs = await SharedPreferences.getInstance();
    const token = 'demo_token_offline';
    await prefs.setString(AppConstants.keyAuthToken, token);
    final user = _demoUser(email, username: username);
    await prefs.setString(AppConstants.keyUserId, user.id);
    return AuthResult(user: user, token: token);
  }

  UserModel _userFromAuthJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'u_demo',
      username: json['username'] as String? ?? 'thinker',
      email: json['email'] as String? ?? 'user@thinkora.ai',
      avatarUrl: json['avatar_url'] as String?,
      displayName: json['display_name'] as String? ?? 'Thinker',
      age: json['age'] as int? ?? 18,
      ageGroup: json['age_group'] as String? ?? 'pioneer',
      country: json['country'] as String? ?? 'Unknown',
      tciRating: TCIRating(
        overall: json['tci_overall'] as int? ?? 500,
        logic: 500,
        memory: 500,
        focus: 500,
        strategy: 500,
        mathematics: 500,
        creativity: 500,
        problemSolving: 500,
        learningSpeed: 500,
      ),
      stats: UserStats(
        totalXp: json['total_xp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        currentStreak: json['current_streak'] as int? ?? 0,
        longestStreak: 0,
        challengesCompleted: 0,
        challengesAttempted: 0,
        battlesWon: 0,
        battlesLost: 0,
        totalPlaytimeMinutes: 0,
      ),
      progress: UserProgress.initial(),
      achievementIds: const [],
      friendIds: const [],
      isParentAccount: false,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  UserModel _demoUser(String email, {String? username}) {
    final name = username ?? email.split('@').first;
    return UserModel(
      id: 'u_demo',
      username: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
      email: email,
      displayName: name.isEmpty ? 'Thinker' : name,
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
  }
}
