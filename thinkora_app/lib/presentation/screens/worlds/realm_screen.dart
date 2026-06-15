import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/realm_model.dart';

class RealmScreen extends StatefulWidget {
  final String realmId;

  const RealmScreen({super.key, required this.realmId});

  @override
  State<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends State<RealmScreen> {
  late RealmModel _realm;

  @override
  void initState() {
    super.initState();
    _realm = RealmModel.allRealms
        .firstWhere((r) => r.id == widget.realmId,
            orElse: () => RealmModel.allRealms.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _realm.color.withOpacity(0.3),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: _realm.gradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _realm.color.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _realm.icon,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ).animate().scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      _realm.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _realm.cognitiveSkill,
                      style: TextStyle(
                        color: _realm.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _realm.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Levels',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = _realm.levels[index];
                  final isFirst = index == 0;
                  final isBoss = (index + 1) % 5 == 0;

                  return GestureDetector(
                    onTap: isFirst || level.isUnlocked
                        ? () => context.go('/challenge/realm_${_realm.id}_$index')
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isFirst || level.isUnlocked
                            ? (isBoss
                                ? LinearGradient(colors: [
                                    AppColors.tciGrandmaster,
                                    AppColors.tciGrandmaster.withOpacity(0.7)
                                  ])
                                : _realm.gradient)
                            : null,
                        color: isFirst || level.isUnlocked
                            ? null
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFirst || level.isUnlocked
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                        boxShadow: isFirst || level.isUnlocked
                            ? [
                                BoxShadow(
                                  color: _realm.color.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isBoss && (isFirst || level.isUnlocked))
                              const Text('👑',
                                  style: TextStyle(fontSize: 16))
                            else if (!isFirst && !level.isUnlocked)
                              const Icon(Icons.lock_outline,
                                  color: AppColors.textMuted, size: 16)
                            else
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            if (isBoss)
                              const Text(
                                'BOSS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate(
                          delay: Duration(milliseconds: index * 30))
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                      );
                },
                childCount: _realm.levels.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
