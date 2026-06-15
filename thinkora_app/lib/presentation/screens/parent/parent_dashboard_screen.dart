import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0=Week, 1=Month

  final _child = const UserModel(
    id: 'child1',
    username: 'youngthinkr',
    email: '',
    displayName: 'Alex',
    age: 12,
    ageGroup: 'scholar',
    country: 'US',
    tciRating: TCIRating(
      overall: 820,
      logic: 880,
      memory: 790,
      focus: 850,
      strategy: 760,
      mathematics: 910,
      creativity: 720,
      problemSolving: 840,
      learningSpeed: 780,
    ),
    stats: UserStats(
      totalXp: 4200,
      level: 5,
      currentStreak: 4,
      longestStreak: 12,
      challengesCompleted: 87,
      challengesAttempted: 102,
      battlesWon: 6,
      battlesLost: 8,
      totalPlaytimeMinutes: 380,
    ),
    progress: UserProgress(
      realmProgress: {},
      completedDailyQuests: [],
      dailyQuestCompletedToday: true,
    ),
    achievementIds: ['streak_3', 'challenges_10'],
    friendIds: [],
    isParentAccount: false,
    parentId: 'parent1',
    createdAt: _d,
    lastActiveAt: _d,
  );

  static final _d = DateTime(2026, 1, 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
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
                Tab(text: 'Overview'),
                Tab(text: 'Progress'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(child: _child),
          _ProgressTab(child: _child),
          const _SettingsTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final UserModel child;

  const _OverviewTab({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child card
          _ChildCard(child: child),
          const SizedBox(height: 20),
          // Today's activity
          _TodayActivity(child: child),
          const SizedBox(height: 20),
          // Cognitive snapshot
          _CognitiveSnapshot(rating: child.tciRating),
          const SizedBox(height: 20),
          // Recommendations for parent
          _ParentRecommendations(child: child),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final UserModel child;

  const _ChildCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                child.displayName.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.displayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${child.ageGroup.replaceFirst(child.ageGroup[0], child.ageGroup[0].toUpperCase())} · Age ${child.age}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (child.progress.dailyQuestCompletedToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✅ Daily Quest Done',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.streakFire.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🔥 ${child.stats.currentStreak} day streak',
                        style: const TextStyle(
                          color: AppColors.streakFire,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _TodayActivity extends StatelessWidget {
  final UserModel child;

  const _TodayActivity({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Activity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActivityItem(
                  icon: '⏱️',
                  value: '18 min',
                  label: 'Time Spent',
                  color: AppColors.logicRealm,
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: '🎯',
                  value: '7',
                  label: 'Challenges',
                  color: AppColors.innovationRealm,
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: '✅',
                  value: '86%',
                  label: 'Accuracy',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _ActivityItem(
                  icon: '⚡',
                  value: '+95 XP',
                  label: 'Earned',
                  color: AppColors.xpGold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
  }
}

class _ActivityItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CognitiveSnapshot extends StatelessWidget {
  final TCIRating rating;

  const _CognitiveSnapshot({required this.rating});

  @override
  Widget build(BuildContext context) {
    final dimensions = [
      ('Logic', rating.logic),
      ('Memory', rating.memory),
      ('Math', rating.mathematics),
      ('Creativity', rating.creativity),
      ('Strategy', rating.strategy),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Cognitive Snapshot',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'TCI ${rating.overall}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dimensions.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      d.$1,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: d.$2 / 1200,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          d.$2 >= 900
                              ? AppColors.success
                              : d.$2 >= 750
                                  ? AppColors.primary
                                  : AppColors.warning,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${d.$2}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms);
  }
}

class _ParentRecommendations extends StatelessWidget {
  final UserModel child;

  const _ParentRecommendations({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations for You',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...[
            (
              '💡',
              'Encourage creativity',
              'Alex\'s creativity score is the lowest. Try open-ended discussions about imaginative topics to reinforce this dimension.',
              AppColors.creativityRealm,
            ),
            (
              '🎯',
              'Optimal session timing',
              'Alex performs best between 4 PM–6 PM based on accuracy data. Consider encouraging sessions after school.',
              AppColors.logicRealm,
            ),
            (
              '🏆',
              'Celebrate the streak',
              'A 4-day streak is building great habits. Acknowledge this achievement to reinforce the behavior.',
              AppColors.success,
            ),
          ].map(
            (rec) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (rec.$4 as Color).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (rec.$4 as Color).withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.$2 as String,
                          style: TextStyle(
                            color: rec.$4 as Color,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rec.$3 as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }
}

class _ProgressTab extends StatelessWidget {
  final UserModel child;

  const _ProgressTab({required this.child});

  @override
  Widget build(BuildContext context) {
    // Weekly XP data simulation
    final weeklyXp = [120, 85, 140, 95, 160, 110, 95];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxXp = weeklyXp.reduce((a, b) => a > b ? a : b).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly XP bar chart
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly XP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: weeklyXp.asMap().entries.map((entry) {
                    final barHeight = (entry.value / maxXp) * 100;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[entry.key],
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Milestones
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Milestones',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ...[
                  ('TCI reached 820 (+45 this week)', '📈', AppColors.primary),
                  ('Completed Logic Realm Level 7', '🧠', AppColors.logicRealm),
                  ('Earned "First Steps" achievement', '🎯', AppColors.xpGold),
                  ('Daily quest completed 4 days in a row', '🔥', AppColors.streakFire),
                ].map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(m.$2, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m.$1 as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _dailyReminders = true;
  bool _weeklyReport = true;
  bool _battleNotifications = false;
  int _dailyTimeLimitMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _SettingItem(
            icon: '⏰',
            title: 'Daily Reminders',
            subtitle: 'Remind Alex to train each day',
            trailing: Switch(
              value: _dailyReminders,
              onChanged: (v) => setState(() => _dailyReminders = v),
            ),
          ),
          const SizedBox(height: 10),
          _SettingItem(
            icon: '📊',
            title: 'Weekly Report',
            subtitle: 'Receive progress emails every Sunday',
            trailing: Switch(
              value: _weeklyReport,
              onChanged: (v) => setState(() => _weeklyReport = v),
            ),
          ),
          const SizedBox(height: 10),
          _SettingItem(
            icon: '⚔️',
            title: 'Battle Notifications',
            subtitle: 'Notify when Alex wins a battle',
            trailing: Switch(
              value: _battleNotifications,
              onChanged: (v) => setState(() => _battleNotifications = v),
            ),
          ),
          const SizedBox(height: 10),
          _SettingItem(
            icon: '⏱️',
            title: 'Daily Time Limit',
            subtitle: '$_dailyTimeLimitMinutes min / day',
            trailing: DropdownButton<int>(
              value: _dailyTimeLimitMinutes,
              dropdownColor: AppColors.card,
              underline: const SizedBox(),
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
              items: [15, 30, 45, 60, 90]
                  .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text('$m min',
                          style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _dailyTimeLimitMinutes = v ?? 30),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
