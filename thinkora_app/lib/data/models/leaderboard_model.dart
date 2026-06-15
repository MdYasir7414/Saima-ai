import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String country;
  final int tciOverall;
  final String tciTier;
  final int weeklyXp;
  final int currentStreak;
  final int challengesCompleted;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.country,
    required this.tciOverall,
    required this.tciTier,
    required this.weeklyXp,
    required this.currentStreak,
    required this.challengesCompleted,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      country: json['country'] as String? ?? '',
      tciOverall: json['tci_overall'] as int,
      tciTier: json['tci_tier'] as String,
      weeklyXp: json['weekly_xp'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      challengesCompleted: json['challenges_completed'] as int? ?? 0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  String get countryFlag {
    if (country.isEmpty) return '🌍';
    final codeUnits = country.toUpperCase().codeUnits;
    if (codeUnits.length != 2) return '🌍';
    return String.fromCharCodes(
        codeUnits.map((c) => c + 127397));
  }

  @override
  List<Object?> get props =>
      [rank, userId, tciOverall, weeklyXp];
}

class LeaderboardData extends Equatable {
  final String scope;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final DateTime lastUpdated;

  const LeaderboardData({
    required this.scope,
    required this.entries,
    this.currentUserEntry,
    required this.lastUpdated,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      scope: json['scope'] as String,
      entries: (json['entries'] as List)
          .map((e) =>
              LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUserEntry: json['current_user_entry'] != null
          ? LeaderboardEntry.fromJson(
              json['current_user_entry'] as Map<String, dynamic>)
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  @override
  List<Object?> get props => [scope, entries, lastUpdated];
}

class BattleSession extends Equatable {
  final String id;
  final String challengeId;
  final String opponentId;
  final String opponentName;
  final String? opponentAvatarUrl;
  final int opponentTci;
  final BattleStatus status;
  final int? userScore;
  final int? opponentScore;
  final bool? userWon;
  final DateTime startedAt;
  final DateTime? endedAt;

  const BattleSession({
    required this.id,
    required this.challengeId,
    required this.opponentId,
    required this.opponentName,
    this.opponentAvatarUrl,
    required this.opponentTci,
    required this.status,
    this.userScore,
    this.opponentScore,
    this.userWon,
    required this.startedAt,
    this.endedAt,
  });

  factory BattleSession.fromJson(Map<String, dynamic> json) {
    return BattleSession(
      id: json['id'] as String,
      challengeId: json['challenge_id'] as String,
      opponentId: json['opponent_id'] as String,
      opponentName: json['opponent_name'] as String,
      opponentAvatarUrl: json['opponent_avatar_url'] as String?,
      opponentTci: json['opponent_tci'] as int,
      status: BattleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BattleStatus.waiting,
      ),
      userScore: json['user_score'] as int?,
      opponentScore: json['opponent_score'] as int?,
      userWon: json['user_won'] as bool?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status, userWon];
}

enum BattleStatus { waiting, active, completed, abandoned }
