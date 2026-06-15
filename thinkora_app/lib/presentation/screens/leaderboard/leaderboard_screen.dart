import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/leaderboard_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedScope = 0;

  static const List<String> _scopes = [
    'Global',
    'Country',
    'Weekly',
    'Age Group',
  ];

  final List<LeaderboardEntry> _entries = List.generate(50, (i) {
    final names = [
      'NeuralStrike',
      'LogicMaster',
      'ThinkTitan',
      'BrainWave',
      'CogEdge',
      'MindForge',
      'IQBlast',
      'StratosX',
      'PuzzleKing',
      'ReasonBot',
    ];
    final countries = ['US', 'IN', 'GB', 'DE', 'JP', 'KR', 'BR', 'CA', 'AU', 'FR'];
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _scopes.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedScope = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myEntry = _entries.firstWhere((e) => e.isCurrentUser);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            expandedHeight: 0,
            title: const Text(
              'Global Rankings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.emoji_events_outlined,
                    color: AppColors.textSecondary),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: AppColors.background,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
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
                  tabs: _scopes.map((s) => Tab(text: s)).toList(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top 3 podium
                  _Podium(entries: _entries.take(3).toList()),
                  const SizedBox(height: 24),
                  // My rank card
                  _MyRankCard(entry: myEntry),
                  const SizedBox(height: 20),
                  // List header
                  const Row(
                    children: [
                      SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          'Player',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'TCI',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 60,
                        child: Text(
                          'Weekly XP',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Entries 4+
                  ...(_entries.skip(3).take(30).toList().asMap().entries.map(
                        (entry) => _LeaderboardRow(
                          leaderboardEntry: entry.value,
                          index: entry.key,
                        ),
                      )),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox();

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd place
          _PodiumItem(entry: entries[1], height: 130, medalColor: const Color(0xFFC0C0C0)),
          const SizedBox(width: 8),
          // 1st place
          _PodiumItem(entry: entries[0], height: 165, medalColor: const Color(0xFFFFD700)),
          const SizedBox(width: 8),
          // 3rd place
          _PodiumItem(entry: entries[2], height: 105, medalColor: const Color(0xFFCD7F32)),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color medalColor;

  const _PodiumItem({
    required this.entry,
    required this.height,
    required this.medalColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: medalColor, width: 2.5),
          ),
          child: Center(
            child: Text(
              entry.displayName.substring(0, 1),
              style: TextStyle(
                color: medalColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.displayName.split(' ').first,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'TCI ${entry.tciOverall}',
          style: TextStyle(
            color: medalColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        // Podium block
        Container(
          width: 88,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: medalColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: medalColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyRankCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _MyRankCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Your Rank',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(entry.countryFlag, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Text(
                  entry.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.tciOverall}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                entry.tciTier,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry leaderboardEntry;
  final int index;

  const _LeaderboardRow({
    required this.leaderboardEntry,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final e = leaderboardEntry;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: e.isCurrentUser
            ? AppColors.primary.withOpacity(0.07)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: e.isCurrentUser
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${e.rank}',
              style: TextStyle(
                color: e.isCurrentUser
                    ? AppColors.primary
                    : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(e.countryFlag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.displayName,
                  style: TextStyle(
                    color: e.isCurrentUser
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  e.tciTier,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${e.tciOverall}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: Text(
              '${e.weeklyXp} xp',
              style: const TextStyle(
                color: AppColors.xpGold,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 30))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}
