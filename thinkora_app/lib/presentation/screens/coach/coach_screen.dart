import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';

class CoachMessage {
  final String content;
  final bool isCoach;
  final DateTime timestamp;
  final String? suggestion;

  const CoachMessage({
    required this.content,
    required this.isCoach,
    required this.timestamp,
    this.suggestion,
  });
}

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _isTyping = false;

  final List<CoachMessage> _messages = [
    CoachMessage(
      content:
          'Hello! I\'m Aura, your personal AI cognitive coach. 🧠\n\nI\'ve analyzed your training data and have some insights for you today.',
      isCoach: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    CoachMessage(
      content:
          '📊 Your Performance Summary:\n\n• Your strongest dimension is **Mathematics** (TCI 1650)\n• Your creativity score (1390) has room to grow\n• You\'ve maintained a 7-day streak — excellent!\n\nRecommendation: Focus on Creativity Realm challenges this week to achieve a more balanced cognitive profile.',
      isCoach: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      suggestion: 'Train Creativity Realm',
    ),
  ];

  final List<String> _quickReplies = [
    'What should I train today?',
    'How do I improve my memory?',
    'Show my weaknesses',
    'Explain my TCI score',
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(CoachMessage(
        content: text,
        isCoach: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final response = _generateResponse(text);
    setState(() {
      _isTyping = false;
      _messages.add(CoachMessage(
        content: response,
        isCoach: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('memory') || lower.contains('remember')) {
      return '💎 **Improving Memory**\n\nHere\'s your personalized memory training plan:\n\n1. **Spaced Repetition** — Review information at increasing intervals\n2. **Memory Palace** — Associate information with vivid locations\n3. **Chunking** — Group information into meaningful units\n\nI recommend starting with the Memory Realm Level 3–5 challenges. They\'re calibrated to your current score of 1480.\n\nShall I queue these challenges for your next session?';
    }
    if (lower.contains('weak') || lower.contains('weakness')) {
      return '🔍 **Your Cognitive Gaps**\n\nBased on your training history:\n\n**Top 3 areas to improve:**\n1. Creativity (1390) — 157 points below your overall average\n2. Learning Speed (1470) — Slightly below average\n3. Memory (1480) — Close to average, can be pushed higher\n\n**Action plan:**\n• 3 Creativity challenges per day\n• 2 Memory challenges\n• 1 cross-domain challenge\n\nThis balanced approach will raise your overall TCI by approximately 80–120 points in 2 weeks.';
    }
    if (lower.contains('today') || lower.contains('train')) {
      return '⚡ **Today\'s Training Plan**\n\nBased on your progress and energy patterns:\n\n**Morning (10 min)**\n• 2× Logic puzzles (warm-up)\n• 1× Pattern recognition\n\n**Afternoon (8 min)**\n• 2× Creativity challenges\n• 1× Memory sequence\n\n**Total:** 5 challenges, ~150 XP, ~+12 TCI\n\nThis will extend your streak to 8 days and push your overall TCI past 1550. Ready to start?';
    }
    if (lower.contains('tci') || lower.contains('score') || lower.contains('rating')) {
      return '📈 **Your TCI Explained**\n\nYour current TCI of **1547** places you in the **Intermediate** tier — top 28% globally for your age group.\n\nYour TCI updates after every challenge using an Elo-style algorithm that accounts for:\n• Challenge difficulty\n• Time taken\n• Accuracy\n• Consistency\n\n**To reach Advanced (TCI 2000):**\n• ~453 points needed\n• Estimated time: 6–8 weeks at current pace\n• Key: focus on harder challenges, not just volume\n\nWant a detailed roadmap to TCI 2000?';
    }
    return '🤔 Great question! I\'m analyzing your cognitive profile to give you the most personalized advice.\n\nBased on your recent performance across 342 challenges, I can see you\'re consistently strong in analytical tasks but sometimes rush creative problems.\n\nMy recommendation: slow down on open-ended challenges and explore multiple approaches before committing to an answer. This will strengthen your divergent thinking.\n\nWould you like me to explain any specific aspect of your cognitive profile?';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aura',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'AI Cognitive Coach',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _TypingIndicator();
                }
                return _ChatBubble(
                  message: _messages[index],
                  onSuggestionTap: (s) => _sendMessage(s),
                );
              },
            ),
          ),
          // Quick replies
          if (_messages.length <= 3)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _sendMessage(_quickReplies[index]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        _quickReplies[index],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_inputController.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final CoachMessage message;
  final ValueChanged<String> onSuggestionTap;

  const _ChatBubble({
    required this.message,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isCoach
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isCoach) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isCoach
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isCoach ? AppColors.card : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isCoach ? 4 : 18),
                      topRight: Radius.circular(message.isCoach ? 18 : 4),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    border: message.isCoach
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isCoach
                          ? AppColors.textPrimary
                          : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                if (message.suggestion != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => onSuggestionTap(message.suggestion!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.4)),
                      ),
                      child: Text(
                        '→ ${message.suggestion}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(),
                    delay: Duration(milliseconds: i * 200),
                  )
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}
