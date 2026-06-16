import 'dart:math';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/challenge_model.dart';

class SubmitResult {
  SubmitResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.xpEarned,
    required this.tciChange,
    required this.dimensionChanges,
    required this.newAchievements,
  });

  final bool isCorrect;
  final String? correctAnswer;
  final String? explanation;
  final int xpEarned;
  final int tciChange;
  final Map<String, int> dimensionChanges;
  final List<String> newAchievements;
}

/// Fetches and submits challenges. Falls back to a built-in challenge bank
/// when the backend is unreachable so training never blocks on the network.
class ChallengeRepository {
  ChallengeRepository({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;
  final _rng = Random();

  Future<ChallengeModel> generate({
    required String realmId,
    required String difficulty,
    String? type,
    String? ageGroup,
  }) async {
    try {
      final res = await _client.get('/challenges/generate', queryParameters: {
        'realmId': realmId,
        'difficulty': difficulty,
        if (type != null) 'type': type,
        if (ageGroup != null) 'ageGroup': ageGroup,
      });
      return ChallengeModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _localChallenge(realmId, difficulty);
      throw ApiException.fromDio(e);
    }
  }

  Future<ChallengeModel> getById(String id) async {
    // Local synthetic ids never hit the network.
    if (id.startsWith('local_') ||
        id.contains('_quick_') ||
        id.contains('realm_') ||
        id.startsWith('daily')) {
      return _localChallengeFromId(id);
    }
    try {
      final res = await _client.get('/challenges/$id');
      return ChallengeModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _localChallengeFromId(id);
      throw ApiException.fromDio(e);
    }
  }

  Future<SubmitResult> submit({
    required ChallengeModel challenge,
    required String? selectedAnswer,
    required int timeSpentSeconds,
  }) async {
    final localGraded = _gradeLocally(
      challenge,
      selectedAnswer,
      timeSpentSeconds,
    );

    // Local challenges grade entirely on-device.
    if (challenge.id.startsWith('local_') ||
        challenge.id.contains('_quick_') ||
        challenge.id.contains('realm_') ||
        challenge.id.startsWith('daily')) {
      return localGraded;
    }

    try {
      final res = await _client.post(
        '/challenges/${challenge.id}/submit',
        data: {
          'selectedAnswer': selectedAnswer,
          'timeSpentSeconds': timeSpentSeconds,
        },
      );
      final data = res.data as Map<String, dynamic>;
      return SubmitResult(
        isCorrect: data['is_correct'] as bool? ?? localGraded.isCorrect,
        correctAnswer: data['correct_answer'] as String?,
        explanation: data['explanation'] as String?,
        xpEarned: data['xp_earned'] as int? ?? localGraded.xpEarned,
        tciChange: data['tci_change'] as int? ?? localGraded.tciChange,
        dimensionChanges: Map<String, int>.from(
          (data['dimension_changes'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, v as int)),
        ),
        newAchievements:
            List<String>.from(data['new_achievements'] as List? ?? []),
      );
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return localGraded;
      throw ApiException.fromDio(e);
    }
  }

  SubmitResult _gradeLocally(
    ChallengeModel c,
    String? selected,
    int timeSpent,
  ) {
    final correct = c.content.options
            ?.any((o) => o.id == selected && o.isCorrect) ??
        (selected == c.content.correctAnswer);
    final speedBonus = timeSpent <= c.timeLimitSeconds * 0.4 ? 2 : 0;
    return SubmitResult(
      isCorrect: correct,
      correctAnswer: c.content.correctAnswer,
      explanation: c.content.explanation,
      xpEarned: correct ? c.xpReward + speedBonus * 5 : (c.xpReward * 0.15).round(),
      tciChange: correct ? c.tciDelta + speedBonus : -(c.tciDelta * 0.4).round(),
      dimensionChanges: c.dimensionDeltas.map(
        (k, v) => MapEntry(k, correct ? v : -(v * 0.25).round()),
      ),
      newAchievements: const [],
    );
  }

  bool _isNetworkFailure(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown ||
        (e.response?.statusCode ?? 0) >= 500;
  }

  ChallengeModel _localChallengeFromId(String id) {
    String realm = 'logic';
    for (final r in ['logic', 'math', 'memory', 'strategy', 'creativity', 'innovation', 'mastermind']) {
      if (id.contains(r)) {
        realm = r;
        break;
      }
    }
    return _localChallenge(realm, 'intermediate', id: id);
  }

  ChallengeModel _localChallenge(String realmId, String difficulty,
      {String? id}) {
    final bank = _challengeBank[realmId] ?? _challengeBank['logic']!;
    final picked = bank[_rng.nextInt(bank.length)];
    return ChallengeModel.fromJson({
      ...picked,
      'id': id ?? 'local_${realmId}_${DateTime.now().millisecondsSinceEpoch}',
      'realm_id': realmId,
      'difficulty': difficulty,
    });
  }

  // A compact on-device bank so every realm has playable content offline.
  static final Map<String, List<Map<String, dynamic>>> _challengeBank = {
    'logic': [
      {
        'title': 'The Truth-Tellers',
        'description': 'A logic deduction puzzle',
        'type': 'logicPuzzle',
        'time_limit_seconds': 90,
        'xp_reward': 30,
        'tci_delta': 8,
        'dimension_deltas': {'logic': 10, 'problem_solving': 6},
        'tags': ['logic', 'deduction'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'On an island, Knights always tell the truth and Knaves always lie.\n\nYou meet two people, X and Y.\nX says: "Y is a Knave."\nY says: "Neither of us is a Knave."\n\nWhat are X and Y?',
          'options': [
            {'id': 'a', 'text': 'X is a Knight, Y is a Knave', 'is_correct': true},
            {'id': 'b', 'text': 'Both are Knights', 'is_correct': false},
            {'id': 'c', 'text': 'Both are Knaves', 'is_correct': false},
            {'id': 'd', 'text': 'X is a Knave, Y is a Knight', 'is_correct': false},
          ],
          'correct_answer': 'a',
          'explanation':
              'If Y were a Knight, Y\'s claim "neither is a Knave" would be true, making X a Knight too — but then X\'s claim that Y is a Knave would be false, a contradiction. So Y is a Knave, making X\'s statement true, so X is a Knight.',
          'hints': [
            'Assume Y is a Knight and look for a contradiction.',
            'A Knave\'s every statement must be false.',
          ],
        },
      },
      {
        'title': 'The Sequence Lock',
        'description': 'Find the rule',
        'type': 'patternRecognition',
        'time_limit_seconds': 60,
        'xp_reward': 28,
        'tci_delta': 7,
        'dimension_deltas': {'logic': 8, 'pattern_recognition': 8},
        'tags': ['logic', 'patterns'],
        'age_group': 'pioneer',
        'content': {
          'prompt': 'Which letter comes next?\n\nO, T, T, F, F, S, S, E, ?',
          'options': [
            {'id': 'a', 'text': 'N', 'is_correct': true},
            {'id': 'b', 'text': 'T', 'is_correct': false},
            {'id': 'c', 'text': 'E', 'is_correct': false},
            {'id': 'd', 'text': 'S', 'is_correct': false},
          ],
          'correct_answer': 'a',
          'explanation':
              'These are the first letters of numbers: One, Two, Three, Four, Five, Six, Seven, Eight — so the next is Nine → N.',
          'hints': ['Say each letter as the start of a word.', 'Think about counting.'],
        },
      },
    ],
    'math': [
      {
        'title': 'The Doubling Pond',
        'description': 'Exponential reasoning',
        'type': 'mathReasoning',
        'time_limit_seconds': 75,
        'xp_reward': 30,
        'tci_delta': 8,
        'dimension_deltas': {'mathematics': 10, 'logic': 5},
        'tags': ['math', 'exponential'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'A lily pad doubles in size every day. It covers the whole pond on day 48.\n\nOn which day was the pond half covered?',
          'options': [
            {'id': 'a', 'text': 'Day 24', 'is_correct': false},
            {'id': 'b', 'text': 'Day 47', 'is_correct': true},
            {'id': 'c', 'text': 'Day 46', 'is_correct': false},
            {'id': 'd', 'text': 'Day 12', 'is_correct': false},
          ],
          'correct_answer': 'b',
          'explanation':
              'If it doubles daily and is full on day 48, the day before (day 47) it must have been exactly half — because doubling half gives the full pond.',
          'hints': ['Work backwards from the full pond.', 'Doubling means the prior day was half.'],
        },
      },
      {
        'title': 'The Missing Number',
        'description': 'Sequence completion',
        'type': 'patternRecognition',
        'time_limit_seconds': 60,
        'xp_reward': 25,
        'tci_delta': 6,
        'dimension_deltas': {'mathematics': 10, 'pattern_recognition': 8},
        'tags': ['math', 'sequences'],
        'age_group': 'pioneer',
        'content': {
          'prompt': 'What comes next?\n\n2, 6, 12, 20, 30, ?',
          'options': [
            {'id': 'a', 'text': '40', 'is_correct': false},
            {'id': 'b', 'text': '42', 'is_correct': true},
            {'id': 'c', 'text': '36', 'is_correct': false},
            {'id': 'd', 'text': '44', 'is_correct': false},
          ],
          'correct_answer': 'b',
          'explanation':
              'The pattern is n(n+1): 1×2=2, 2×3=6, 3×4=12, 4×5=20, 5×6=30, 6×7=42.',
          'hints': ['Look at the gaps: 4, 6, 8, 10…', 'Each gap grows by 2.'],
        },
      },
    ],
    'memory': [
      {
        'title': 'Position Recall',
        'description': 'Working memory test',
        'type': 'memorySequence',
        'time_limit_seconds': 30,
        'xp_reward': 20,
        'tci_delta': 5,
        'dimension_deltas': {'memory': 12, 'focus': 6},
        'tags': ['memory', 'recall'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'Memorize this order:\n\n🍎 → 🚗 → 📚 → 🌙 → 🎸\n\nWhich item was in position 4?',
          'options': [
            {'id': 'a', 'text': '🚗 Car', 'is_correct': false},
            {'id': 'b', 'text': '🌙 Moon', 'is_correct': true},
            {'id': 'c', 'text': '📚 Book', 'is_correct': false},
            {'id': 'd', 'text': '🎸 Guitar', 'is_correct': false},
          ],
          'correct_answer': 'b',
          'explanation': 'Order: Apple(1), Car(2), Book(3), Moon(4), Guitar(5). Position 4 is the Moon.',
          'hints': ['Count carefully from the start.'],
        },
      },
    ],
    'strategy': [
      {
        'title': 'The Resource Dilemma',
        'description': 'Strategic decision-making',
        'type': 'strategyPuzzle',
        'time_limit_seconds': 120,
        'xp_reward': 35,
        'tci_delta': 9,
        'dimension_deltas': {'strategy': 12, 'problem_solving': 7},
        'tags': ['strategy', 'planning'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'You have 100 food. Each turn you may:\n• Farm: cost 30, yields 25/turn forever\n• School: cost 50, boosts all future farm yield by 40%\n\nWith only 2 turns, which order maximizes long-term yield?',
          'options': [
            {'id': 'a', 'text': 'Farm, then Farm', 'is_correct': false},
            {'id': 'b', 'text': 'School, then Farm', 'is_correct': true},
            {'id': 'c', 'text': 'Farm, then School', 'is_correct': false},
            {'id': 'd', 'text': 'School, then School', 'is_correct': false},
          ],
          'correct_answer': 'b',
          'explanation':
              'School first means the farm built afterward yields 25×1.4 = 35/turn forever. Farm-then-School only boosts farms you build later (none), wasting the multiplier. Compounding the boost before building beats raw output.',
          'hints': ['The school only helps farms built after it.', 'Think compounding, not immediate output.'],
        },
      },
    ],
    'creativity': [
      {
        'title': 'Divergent Uses',
        'description': 'Creative thinking',
        'type': 'creativityChallenge',
        'time_limit_seconds': 60,
        'xp_reward': 25,
        'tci_delta': 6,
        'dimension_deltas': {'creativity': 12, 'problem_solving': 4},
        'tags': ['creativity'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'Which use of a paperclip shows the MOST divergent (creative) thinking?',
          'options': [
            {'id': 'a', 'text': 'Hold papers together', 'is_correct': false},
            {'id': 'b', 'text': 'A bookmark', 'is_correct': false},
            {'id': 'c', 'text': 'Reshape into a tiny antenna to conduct a circuit', 'is_correct': true},
            {'id': 'd', 'text': 'Clip a bag shut', 'is_correct': false},
          ],
          'correct_answer': 'c',
          'explanation':
              'Divergent thinking rewards remote, non-obvious uses. The others are conventional; repurposing a paperclip as a conductive antenna transforms its function entirely.',
          'hints': ['The most creative answer changes what the object fundamentally does.'],
        },
      },
    ],
    'innovation': [
      {
        'title': 'First Principles',
        'description': 'Reason from fundamentals',
        'type': 'logicPuzzle',
        'time_limit_seconds': 120,
        'xp_reward': 60,
        'tci_delta': 15,
        'dimension_deltas': {'logic': 12, 'creativity': 10, 'problem_solving': 14},
        'tags': ['innovation', 'first-principles'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'A startup may pivot in 6 months. Internet options:\n• A: \$400/mo, 20% slower\n• B: \$350/mo, 2-year lock-in\n• C: \$480/mo, 30% faster, month-to-month\n\nReasoning from first principles, which is best?',
          'options': [
            {'id': 'a', 'text': 'A — cheapest flexible', 'is_correct': false},
            {'id': 'b', 'text': 'B — best price', 'is_correct': false},
            {'id': 'c', 'text': 'C — preserves optionality', 'is_correct': true},
            {'id': 'd', 'text': 'Keep current plan', 'is_correct': false},
          ],
          'correct_answer': 'c',
          'explanation':
              'The startup\'s core constraint is uncertainty. B\'s 2-year lock-in carries a high optionality cost against a likely pivot. A\'s slower speed is a hidden productivity tax. C keeps month-to-month flexibility AND adds speed for growth — optionality value outweighs the small price premium.',
          'hints': ['What is the dominant constraint here?', 'Price is not the only cost — flexibility has value.'],
        },
      },
    ],
    'mastermind': [
      {
        'title': 'The Hat Logicians',
        'description': 'Higher-order reasoning',
        'type': 'logicPuzzle',
        'time_limit_seconds': 180,
        'xp_reward': 150,
        'tci_delta': 25,
        'dimension_deltas': {'logic': 18, 'strategy': 15, 'problem_solving': 20},
        'tags': ['mastermind', 'epistemic'],
        'age_group': 'pioneer',
        'content': {
          'prompt':
              'Three perfect logicians wear hats, each Red or Blue, and can see the others\' but not their own. At least one is Red.\n\nAsked in turn "Do you know your color?", the first two say "No". The third says "Yes".\n\nWhat color is the third?',
          'options': [
            {'id': 'a', 'text': 'Red', 'is_correct': true},
            {'id': 'b', 'text': 'Blue', 'is_correct': false},
            {'id': 'c', 'text': 'Cannot be determined', 'is_correct': false},
            {'id': 'd', 'text': 'Depends on the others', 'is_correct': false},
          ],
          'correct_answer': 'a',
          'explanation':
              'If the third saw two Blue hats, knowing at least one is Red, they\'d instantly know they were Red. The first two saying "No" tells the third the configuration isn\'t one that would let anyone answer early — and combined with what the third sees, the only consistent deduction is that the third\'s own hat is Red.',
          'hints': [
            'Use the "at least one Red" rule.',
            'Each "No" is information for the next logician.',
          ],
        },
      },
    ],
  };
}
