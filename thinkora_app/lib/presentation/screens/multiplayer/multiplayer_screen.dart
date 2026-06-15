import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/models/leaderboard_model.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMatchmaking = false;
  int _matchmakingSeconds = 0;
  Timer? _matchmakingTimer;

  final List<BattleSession> _recentBattles = [
    BattleSession(
      id: 'b1',
      challengeId: 'c1',
      opponentId: 'u2',
      opponentName: 'LogicMaster42',
      opponentTci: 1680,
      status: BattleStatus.completed,
      userScore: 95,
      opponentScore: 70,
      userWon: true,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      endedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BattleSession(
      id: 'b2',
      challengeId: 'c2',
      opponentId: 'u3',
      opponentName: 'BrainWave99',
      opponentTci: 1820,
      status: BattleStatus.completed,
      userScore: 60,
      opponentScore: 90,
      userWon: false,
      startedAt: DateTime.now().subtract(const Duration(days: 1)),
      endedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BattleSession(
      id: 'b3',
      challengeId: 'c3',
      opponentId: 'u4',
      opponentName: 'ThinkTitan7',
      opponentTci: 1490,
      status: BattleStatus.completed,
      userScore: 100,
      opponentScore: 55,
      userWon: true,
      startedAt: DateTime.now().subtract(const Duration(days: 2)),
      endedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _matchmakingTimer?.cancel();
    super.dispose();
  }

  void _startMatchmaking() {
    setState(() {
      _isMatchmaking = true;
      _matchmakingSeconds = 0;
    });

    _matchmakingTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _matchmakingSeconds++);

      // Simulate finding a match after 5 seconds
      if (_matchmakingSeconds >= 5) {
        timer.cancel();
        _foundMatch();
      }
    });
  }

  void _foundMatch() {
    setState(() => _isMatchmaking = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MatchFoundDialog(
        opponentName: 'StratosX_${DateTime.now().second}',
        opponentTci: 1520 + (_matchmakingSeconds * 10),
        onAccept: () {
          Navigator.pop(context);
          // Navigate to battle
        },
        onDecline: () => Navigator.pop(context),
      ),
    );
  }

  void _cancelMatchmaking() {
    _matchmakingTimer?.cancel();
    setState(() => _isMatchmaking = false);
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
        title: const Text(
          'Brain Battles',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              tabs: const [
                Tab(text: 'Quick Battle'),
                Tab(text: 'Tournaments'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QuickBattleTab(
            isMatchmaking: _isMatchmaking,
            matchmakingSeconds: _matchmakingSeconds,
            onStart: _startMatchmaking,
            onCancel: _cancelMatchmaking,
          ),
          const _TournamentsTab(),
          _HistoryTab(battles: _recentBattles),
        ],
      ),
    );
  }
}

class _QuickBattleTab extends StatelessWidget {
  final bool isMatchmaking;
  final int matchmakingSeconds;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const _QuickBattleTab({
    required this.isMatchmaking,
    required this.matchmakingSeconds,
    required this.onStart,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Battle modes
          const Text(
            'Choose Battle Mode',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          const Text(
            'Compete against players near your TCI rating.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ).animate(delay: 50.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 30),
          // Battle type cards
          ...([
            {
              'icon': '⚔️',
              'title': 'Logic Duel',
              'description': '1v1 logic puzzle race',
              'time': '90 seconds',
              'color': AppColors.logicRealm,
            },
            {
              'icon': '🧩',
              'title': 'Puzzle Sprint',
              'description': '5 challenges, fastest wins',
              'time': '5 minutes',
              'color': AppColors.strategyRealm,
            },
            {
              'icon': '🧠',
              'title': 'Math Battle',
              'description': 'Speed math competition',
              'time': '60 seconds',
              'color': AppColors.mathRealm,
            },
          ].asMap().entries.map(
                (entry) => GestureDetector(
                  onTap: isMatchmaking ? null : onStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (entry.value['color'] as Color)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (entry.value['color'] as Color)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              entry.value['icon'] as String,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['title'] as String,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                entry.value['description'] as String,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (entry.value['color'] as Color)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.value['time'] as String,
                            style: TextStyle(
                              color: entry.value['color'] as Color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(
                        delay: Duration(milliseconds: entry.key * 80))
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              )),
          const SizedBox(height: 24),
          if (isMatchmaking)
            _MatchmakingIndicator(seconds: matchmakingSeconds, onCancel: onCancel)
          else
            GradientButton(
              text: '⚡  Find Opponent',
              onPressed: onStart,
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          // My battle record
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BattleStat(value: '28', label: 'Won', icon: '🏆'),
                _BattleStat(value: '14', label: 'Lost', icon: '💔'),
                _BattleStat(value: '67%', label: 'Win Rate', icon: '📈'),
                _BattleStat(value: '#247', label: 'Battle Rank', icon: '⚔️'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchmakingIndicator extends StatelessWidget {
  final int seconds;
  final VoidCallback onCancel;

  const _MatchmakingIndicator({
    required this.seconds,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1500.ms),
          const SizedBox(height: 16),
          const Text(
            'Finding your match...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Searching for ${seconds}s · TCI ~1547',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleStat extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _BattleStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _TournamentsTab extends StatelessWidget {
  const _TournamentsTab();

  @override
  Widget build(BuildContext context) {
    final tournaments = [
      {
        'name': 'Weekly Logic Cup',
        'type': 'Logic',
        'participants': 2841,
        'prize': '5000 XP + Badge',
        'timeLeft': '3d 12h',
        'status': 'Active',
        'color': AppColors.logicRealm,
      },
      {
        'name': 'Monthly Masters',
        'type': 'All Dimensions',
        'participants': 15200,
        'prize': '25000 XP + Trophy',
        'timeLeft': '12d 4h',
        'status': 'Registering',
        'color': AppColors.tciGrandmaster,
      },
      {
        'name': 'Strategy Showdown',
        'type': 'Strategy',
        'participants': 1120,
        'prize': '3000 XP',
        'timeLeft': '1d 6h',
        'status': 'Active',
        'color': AppColors.strategyRealm,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: tournaments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = tournaments[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (t['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: t['status'] == 'Active'
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t['status'] as String,
                      style: TextStyle(
                        color: t['status'] == 'Active'
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '⏱ ${t['timeLeft']}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t['name'] as String,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${t['type']} · ${t['participants']} participants',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('🏆 Prize: ',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                  Text(
                    t['prize'] as String,
                    style: const TextStyle(
                      color: AppColors.xpGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t['color'] as Color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Join',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<BattleSession> battles;

  const _HistoryTab({required this.battles});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: battles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = battles[index];
        final won = b.userWon ?? false;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: won
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: won
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    won ? '🏆' : '💔',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.opponentName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'TCI ${b.opponentTci}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${b.userScore} — ${b.opponentScore}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    won ? '+75 XP' : '+10 XP',
                    style: const TextStyle(
                      color: AppColors.xpGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: index * 60))
            .fadeIn(duration: 300.ms);
      },
    );
  }
}

class _MatchFoundDialog extends StatelessWidget {
  final String opponentName;
  final int opponentTci;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _MatchFoundDialog({
    required this.opponentName,
    required this.opponentTci,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Match Found!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Opponent: $opponentName',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            'TCI $opponentTci',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          GradientButton(text: 'Accept Battle', onPressed: onAccept),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onDecline,
            child: const Text('Decline',
                style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}
