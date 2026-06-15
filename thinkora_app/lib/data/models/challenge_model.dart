import 'package:equatable/equatable.dart';

enum ChallengeType {
  logicPuzzle,
  patternRecognition,
  memorySequence,
  mathReasoning,
  spatialReasoning,
  verbalReasoning,
  decisionSimulation,
  strategyPuzzle,
  creativityChallenge,
  wordAssociation,
}

enum ChallengeDifficulty { beginner, intermediate, advanced, expert, master }

class ChallengeModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final String realmId;
  final ChallengeContent content;
  final int timeLimitSeconds;
  final int xpReward;
  final int tciDelta;
  final Map<String, int> dimensionDeltas;
  final List<String> tags;
  final String ageGroup;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.realmId,
    required this.content,
    required this.timeLimitSeconds,
    required this.xpReward,
    required this.tciDelta,
    required this.dimensionDeltas,
    required this.tags,
    required this.ageGroup,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.logicPuzzle,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ChallengeDifficulty.beginner,
      ),
      realmId: json['realm_id'] as String,
      content:
          ChallengeContent.fromJson(json['content'] as Map<String, dynamic>),
      timeLimitSeconds: json['time_limit_seconds'] as int? ?? 60,
      xpReward: json['xp_reward'] as int? ?? 30,
      tciDelta: json['tci_delta'] as int? ?? 5,
      dimensionDeltas: Map<String, int>.from(
        (json['dimension_deltas'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as int)),
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      ageGroup: json['age_group'] as String? ?? 'pioneer',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'difficulty': difficulty.name,
        'realm_id': realmId,
        'content': content.toJson(),
        'time_limit_seconds': timeLimitSeconds,
        'xp_reward': xpReward,
        'tci_delta': tciDelta,
        'dimension_deltas': dimensionDeltas,
        'tags': tags,
        'age_group': ageGroup,
      };

  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        return 'Beginner';
      case ChallengeDifficulty.intermediate:
        return 'Intermediate';
      case ChallengeDifficulty.advanced:
        return 'Advanced';
      case ChallengeDifficulty.expert:
        return 'Expert';
      case ChallengeDifficulty.master:
        return 'Master';
    }
  }

  String get typeLabel {
    switch (type) {
      case ChallengeType.logicPuzzle:
        return 'Logic Puzzle';
      case ChallengeType.patternRecognition:
        return 'Pattern Recognition';
      case ChallengeType.memorySequence:
        return 'Memory Sequence';
      case ChallengeType.mathReasoning:
        return 'Math Reasoning';
      case ChallengeType.spatialReasoning:
        return 'Spatial Reasoning';
      case ChallengeType.verbalReasoning:
        return 'Verbal Reasoning';
      case ChallengeType.decisionSimulation:
        return 'Decision Simulation';
      case ChallengeType.strategyPuzzle:
        return 'Strategy Puzzle';
      case ChallengeType.creativityChallenge:
        return 'Creativity Challenge';
      case ChallengeType.wordAssociation:
        return 'Word Association';
    }
  }

  @override
  List<Object> get props => [id, title, type, difficulty, realmId];
}

class ChallengeContent extends Equatable {
  final String prompt;
  final List<ChallengeOption>? options;
  final String? correctAnswer;
  final String? explanation;
  final Map<String, dynamic>? gameData;
  final List<String>? hints;

  const ChallengeContent({
    required this.prompt,
    this.options,
    this.correctAnswer,
    this.explanation,
    this.gameData,
    this.hints,
  });

  factory ChallengeContent.fromJson(Map<String, dynamic> json) {
    return ChallengeContent(
      prompt: json['prompt'] as String,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((o) =>
                  ChallengeOption.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
      correctAnswer: json['correct_answer'] as String?,
      explanation: json['explanation'] as String?,
      gameData: json['game_data'] as Map<String, dynamic>?,
      hints: json['hints'] != null
          ? List<String>.from(json['hints'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'options': options?.map((o) => o.toJson()).toList(),
        'correct_answer': correctAnswer,
        'explanation': explanation,
        'game_data': gameData,
        'hints': hints,
      };

  @override
  List<Object?> get props => [prompt, options, correctAnswer];
}

class ChallengeOption extends Equatable {
  final String id;
  final String text;
  final bool isCorrect;

  const ChallengeOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory ChallengeOption.fromJson(Map<String, dynamic> json) {
    return ChallengeOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_correct': isCorrect,
      };

  @override
  List<Object> get props => [id, text, isCorrect];
}

class ChallengeResult extends Equatable {
  final String challengeId;
  final bool isCorrect;
  final int timeSpentSeconds;
  final String? selectedAnswer;
  final int xpEarned;
  final int tciChange;
  final Map<String, int> dimensionChanges;
  final DateTime completedAt;

  const ChallengeResult({
    required this.challengeId,
    required this.isCorrect,
    required this.timeSpentSeconds,
    this.selectedAnswer,
    required this.xpEarned,
    required this.tciChange,
    required this.dimensionChanges,
    required this.completedAt,
  });

  factory ChallengeResult.fromJson(Map<String, dynamic> json) {
    return ChallengeResult(
      challengeId: json['challenge_id'] as String,
      isCorrect: json['is_correct'] as bool,
      timeSpentSeconds: json['time_spent_seconds'] as int,
      selectedAnswer: json['selected_answer'] as String?,
      xpEarned: json['xp_earned'] as int,
      tciChange: json['tci_change'] as int,
      dimensionChanges: Map<String, int>.from(
        (json['dimension_changes'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, v as int)),
      ),
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [challengeId, isCorrect, timeSpentSeconds, xpEarned];
}

class DailyQuest extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> challengeIds;
  final int totalXpReward;
  final int completedCount;
  final bool isCompleted;
  final DateTime date;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.challengeIds,
    required this.totalXpReward,
    required this.completedCount,
    required this.isCompleted,
    required this.date,
  });

  int get totalChallenges => challengeIds.length;
  double get progressRate =>
      totalChallenges == 0 ? 0 : completedCount / totalChallenges;

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      challengeIds: List<String>.from(json['challenge_ids'] as List),
      totalXpReward: json['total_xp_reward'] as int,
      completedCount: json['completed_count'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
    );
  }

  @override
  List<Object> get props => [id, date, isCompleted, completedCount];
}
