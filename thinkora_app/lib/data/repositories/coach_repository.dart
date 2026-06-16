import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Talks to the AI coach endpoint, with an on-device heuristic responder
/// used when the backend (and its LLM) is unavailable.
class CoachRepository {
  CoachRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<String> sendMessage(String message) async {
    try {
      final res = await _client.post('/coach/chat', data: {'message': message});
      return res.data['response'] as String? ?? _fallback(message);
    } on DioException catch (e) {
      if (_isNetworkFailure(e)) return _fallback(message);
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

  String _fallback(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('memory') || lower.contains('remember')) {
      return '💎 **Improving Memory**\n\nTry these evidence-based techniques:\n\n1. **Spaced repetition** — review at growing intervals\n2. **Chunking** — group items into meaningful units\n3. **Memory palace** — anchor items to vivid places\n\nStart with Memory Realm Levels 3–5, calibrated to your current rating.';
    }
    if (lower.contains('weak')) {
      return '🔍 **Your Cognitive Gaps**\n\nBased on your profile, creativity and learning speed have the most room to grow. A balanced plan:\n• 3 creativity challenges/day\n• 2 memory challenges\n• 1 cross-domain challenge\n\nThis should lift your overall TCI by ~80–120 points over two weeks.';
    }
    if (lower.contains('today') || lower.contains('train')) {
      return '⚡ **Today\'s Plan**\n\n• 2× Logic puzzles (warm-up)\n• 1× Pattern recognition\n• 2× Creativity challenges\n\nTotal: ~12 minutes, ~150 XP. This keeps your streak alive and pushes your TCI upward.';
    }
    if (lower.contains('tci') || lower.contains('score') || lower.contains('rating')) {
      return '📈 **Your TCI Explained**\n\nTCI updates after every challenge using an Elo-style model that weighs difficulty, speed, accuracy, and consistency. To climb faster, prioritize *harder* challenges over sheer volume — difficulty drives the biggest rating gains.';
    }
    return '🤔 Great question! Based on your recent sessions, you\'re strong analytically but tend to rush open-ended problems. Slow down on creative challenges and explore multiple approaches before committing — that strengthens divergent thinking. What would you like to focus on?';
  }
}
