import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_colors.dart';

class RealmModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;
  final LinearGradient gradient;
  final List<RealmLevel> levels;
  final int totalLevels;
  final String cognitiveSkill;
  final String unlockRequirement;
  final bool isLocked;

  const RealmModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.levels,
    required this.totalLevels,
    required this.cognitiveSkill,
    required this.unlockRequirement,
    required this.isLocked,
  });

  static List<RealmModel> get allRealms => [
        RealmModel(
          id: 'logic',
          name: 'Logic Realm',
          description:
              'Master deductive reasoning, critical thinking, and logical inference',
          icon: '🧠',
          color: AppColors.logicRealm,
          gradient: AppColors.logicGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Logic Level ${i + 1}',
                    isUnlocked: i == 0,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Logical Reasoning',
          unlockRequirement: 'Available from start',
          isLocked: false,
        ),
        RealmModel(
          id: 'strategy',
          name: 'Strategy Realm',
          description:
              'Develop strategic thinking, planning, and long-term decision making',
          icon: '♟️',
          color: AppColors.strategyRealm,
          gradient: AppColors.strategyGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Strategy Level ${i + 1}',
                    isUnlocked: i == 0,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Strategic Planning',
          unlockRequirement: 'TCI 600+',
          isLocked: false,
        ),
        RealmModel(
          id: 'memory',
          name: 'Memory Realm',
          description:
              'Strengthen working memory, recall precision, and information retention',
          icon: '💎',
          color: AppColors.memoryRealm,
          gradient: AppColors.memoryGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Memory Level ${i + 1}',
                    isUnlocked: i == 0,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Memory & Recall',
          unlockRequirement: 'TCI 700+',
          isLocked: false,
        ),
        RealmModel(
          id: 'math',
          name: 'Math Realm',
          description:
              'Build numerical intelligence, quantitative reasoning, and mathematical intuition',
          icon: '∑',
          color: AppColors.mathRealm,
          gradient: AppColors.mathGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Math Level ${i + 1}',
                    isUnlocked: i == 0,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Mathematical Intelligence',
          unlockRequirement: 'TCI 800+',
          isLocked: false,
        ),
        RealmModel(
          id: 'creativity',
          name: 'Creativity Realm',
          description:
              'Expand divergent thinking, creative problem-solving, and innovative ideation',
          icon: '✨',
          color: AppColors.creativityRealm,
          gradient: AppColors.creativityGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Creativity Level ${i + 1}',
                    isUnlocked: i == 0,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Creative Thinking',
          unlockRequirement: 'TCI 1000+',
          isLocked: false,
        ),
        RealmModel(
          id: 'innovation',
          name: 'Innovation Realm',
          description:
              'Apply systems thinking, first-principles reasoning, and breakthrough problem-solving',
          icon: '⚡',
          color: AppColors.innovationRealm,
          gradient: AppColors.innovationGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Innovation Level ${i + 1}',
                    isUnlocked: i < 1,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Systems Thinking',
          unlockRequirement: 'TCI 1500+',
          isLocked: true,
        ),
        RealmModel(
          id: 'mastermind',
          name: 'Mastermind Realm',
          description:
              'The ultimate cognitive challenge — elite reasoning across all dimensions',
          icon: '👑',
          color: AppColors.mastermindRealm,
          gradient: AppColors.mastermindGradient,
          levels: List.generate(
              20,
              (i) => RealmLevel(
                    levelNumber: i + 1,
                    title: 'Mastermind Level ${i + 1}',
                    isUnlocked: false,
                    isCompleted: false,
                    stars: 0,
                  )),
          totalLevels: 20,
          cognitiveSkill: 'Elite Cognition',
          unlockRequirement: 'TCI 2000+',
          isLocked: true,
        ),
      ];

  @override
  List<Object> get props => [id, name, isLocked, totalLevels];
}

class RealmLevel extends Equatable {
  final int levelNumber;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;

  const RealmLevel({
    required this.levelNumber,
    required this.title,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
  });

  @override
  List<Object> get props =>
      [levelNumber, isUnlocked, isCompleted, stars];
}
