import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/models/challenge_model.dart';
import '../../blocs/user/user_cubit.dart';

class ChallengeScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeScreen({super.key, required this.challengeId});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  Timer? _timer;
  int _timeRemaining = 60;
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _hintsUsed = 0;
  bool _showHint = false;

  // Demo challenge
  late ChallengeModel _challenge;

  @override
  void initState() {
    super.initState();
    _challenge = _generateDemoChallenge(widget.challengeId);
    _timeRemaining = _challenge.timeLimitSeconds;
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _challenge.timeLimitSeconds),
    );
    _startTimer();
  }

  ChallengeModel _generateDemoChallenge(String id) {
    final challenges = {
      'logic_quick_1': ChallengeModel(
        id: 'logic_quick_1',
        title: 'The Detective\'s Deduction',
        description: 'A classic logic deduction puzzle',
        type: ChallengeType.logicPuzzle,
        difficulty: ChallengeDifficulty.intermediate,
        realmId: 'logic',
        content: ChallengeContent(
          prompt:
              'Alice, Bob, and Carol each have a different pet: a cat, a dog, and a bird.\n\n• Alice does not have the cat.\n• Bob does not have the dog.\n• Carol does not have the bird.\n• The person with the dog is not Alice.\n\nWho has the cat?',
          options: const [
            ChallengeOption(id: 'a', text: 'Alice', isCorrect: false),
            ChallengeOption(id: 'b', text: 'Bob', isCorrect: true),
            ChallengeOption(id: 'c', text: 'Carol', isCorrect: false),
            ChallengeOption(id: 'd', text: 'Cannot be determined', isCorrect: false),
          ],
          correctAnswer: 'b',
          explanation:
              'From the clues: Alice has neither cat nor dog (clues 1 & 4), so Alice has the bird. Carol has neither bird nor... wait — Carol doesn\'t have the bird (clue 3), but Alice does. So Carol has cat or dog. Bob doesn\'t have the dog (clue 2), so Bob has the cat. Carol has the dog.',
          hints: const [
            'Start by eliminating what Alice cannot have.',
            'Alice cannot have the cat AND cannot have the dog. What does that leave?',
          ],
        ),
        timeLimitSeconds: 90,
        xpReward: 30,
        tciDelta: 8,
        dimensionDeltas: const {'logic': 10, 'problem_solving': 6},
        tags: const ['logic', 'deduction'],
        ageGroup: 'pioneer',
      ),
      'math_quick_1': ChallengeModel(
        id: 'math_quick_1',
        title: 'The Missing Number',
        description: 'Find the pattern and complete the sequence',
        type: ChallengeType.patternRecognition,
        difficulty: ChallengeDifficulty.beginner,
        realmId: 'math',
        content: ChallengeContent(
          prompt:
              'What comes next in this sequence?\n\n2, 6, 12, 20, 30, ?',
          options: const [
            ChallengeOption(id: 'a', text: '40', isCorrect: false),
            ChallengeOption(id: 'b', text: '42', isCorrect: true),
            ChallengeOption(id: 'c', text: '36', isCorrect: false),
            ChallengeOption(id: 'd', text: '44', isCorrect: false),
          ],
          correctAnswer: 'b',
          explanation:
              'The pattern is n(n+1): 1×2=2, 2×3=6, 3×4=12, 4×5=20, 5×6=30, 6×7=42.',
          hints: const [
            'Look at the differences between consecutive numbers: 4, 6, 8, 10...',
            'The differences increase by 2 each time.',
          ],
        ),
        timeLimitSeconds: 60,
        xpReward: 25,
        tciDelta: 6,
        dimensionDeltas: const {'mathematics': 10, 'pattern_recognition': 8},
        tags: const ['math', 'patterns', 'sequences'],
        ageGroup: 'pioneer',
      ),
    };

    return challenges[id] ?? challenges['logic_quick_1']!;
  }

  void _startTimer() {
    _timerController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 0) {
        _timer?.cancel();
        _submitAnswer(null);
      } else {
        setState(() => _timeRemaining--);
      }
    });
  }

  void _selectAnswer(String answerId) {
    if (_isAnswered) return;
    setState(() => _selectedAnswer = answerId);
  }

  void _submitAnswer(String? answerId) {
    if (_isAnswered) return;
    _timer?.cancel();

    final isCorrect = answerId != null &&
        _challenge.content.options!
            .any((o) => o.id == answerId && o.isCorrect);

    final xpEarned = isCorrect ? _challenge.xpReward : 5;
    final tciChange = isCorrect ? _challenge.tciDelta : -3;

    setState(() => _isAnswered = true);

    // Apply progress optimistically so the home screen reflects the result immediately
    context.read<UserCubit>().applyResult(
          isCorrect: isCorrect,
          xpEarned: xpEarned,
          tciChange: tciChange,
          dimensionChanges: _challenge.dimensionDeltas,
        );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.go(
        AppRoutes.challengeResult,
        extra: {
          'isCorrect': isCorrect,
          'xpEarned': xpEarned,
          'tciChange': tciChange,
          'timeSpent': _challenge.timeLimitSeconds - _timeRemaining,
          'challenge': _challenge,
          'correctAnswer': _challenge.content.correctAnswer,
          'selectedAnswer': answerId,
          'explanation': _challenge.content.explanation,
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _ChallengeHeader(
              challenge: _challenge,
              timeRemaining: _timeRemaining,
              timerController: _timerController,
              onClose: () => context.pop(),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.logicRealm.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _challenge.typeLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.logicRealm,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 14),
                    // Title
                    Text(
                      _challenge.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ).animate(delay: 50.ms).fadeIn(duration: 300.ms),
                    const SizedBox(height: 20),
                    // Prompt
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _challenge.content.prompt,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                    // Hint section
                    if (_challenge.content.hints != null && _hintsUsed == 0)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showHint = true;
                            _hintsUsed++;
                          });
                        },
                        icon: const Icon(Icons.lightbulb_outline,
                            color: AppColors.warning, size: 18),
                        label: const Text(
                          'Use a hint (-5 XP)',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (_showHint && _challenge.content.hints != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('💡',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _challenge.content
                                    .hints![_hintsUsed - 1],
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    // Answer options
                    if (_challenge.content.options != null) ...[
                      const Text(
                        'Choose your answer:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(_challenge.content.options!.asMap().entries.map(
                            (entry) => _AnswerOption(
                              option: entry.value,
                              index: entry.key,
                              isSelected:
                                  _selectedAnswer == entry.value.id,
                              isAnswered: _isAnswered,
                              onTap: () =>
                                  _selectAnswer(entry.value.id),
                            ),
                          )),
                    ],
                    const SizedBox(height: 24),
                    if (_selectedAnswer != null && !_isAnswered)
                      GradientButton(
                        text: 'Submit Answer',
                        onPressed: () => _submitAnswer(_selectedAnswer),
                      ).animate().fadeIn(duration: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeHeader extends StatelessWidget {
  final ChallengeModel challenge;
  final int timeRemaining;
  final AnimationController timerController;
  final VoidCallback onClose;

  const _ChallengeHeader({
    required this.challenge,
    required this.timeRemaining,
    required this.timerController,
    required this.onClose,
  });

  Color get _timerColor {
    if (timeRemaining > 30) return AppColors.success;
    if (timeRemaining > 10) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: timerController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: 1 - timerController.value,
                  backgroundColor: AppColors.border,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_timerColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timerColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _timerColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: _timerColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${timeRemaining}s',
                  style: TextStyle(
                    color: _timerColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _AnswerOption extends StatelessWidget {
  final ChallengeOption option;
  final int index;
  final bool isSelected;
  final bool isAnswered;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isAnswered,
    required this.onTap,
  });

  static const List<String> _labels = ['A', 'B', 'C', 'D'];

  Color _getBorderColor() {
    if (!isAnswered) {
      return isSelected ? AppColors.primary : AppColors.border;
    }
    if (option.isCorrect) return AppColors.success;
    if (isSelected && !option.isCorrect) return AppColors.error;
    return AppColors.border;
  }

  Color _getBackgroundColor() {
    if (!isAnswered) {
      return isSelected
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface;
    }
    if (option.isCorrect) return AppColors.success.withOpacity(0.1);
    if (isSelected && !option.isCorrect) {
      return AppColors.error.withOpacity(0.1);
    }
    return AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected || (isAnswered && option.isCorrect) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected && !isAnswered
                    ? AppColors.primary
                    : isAnswered && option.isCorrect
                        ? AppColors.success
                        : isAnswered && isSelected && !option.isCorrect
                            ? AppColors.error
                            : AppColors.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isAnswered && option.isCorrect
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : isAnswered && isSelected && !option.isCorrect
                        ? const Icon(Icons.close, color: Colors.white, size: 16)
                        : Text(
                            _labels[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: isAnswered && option.isCorrect
                      ? AppColors.success
                      : isAnswered && isSelected && !option.isCorrect
                          ? AppColors.error
                          : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 150 + index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
