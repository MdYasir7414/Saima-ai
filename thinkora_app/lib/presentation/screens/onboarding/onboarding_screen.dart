import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/gradient_button.dart';

class OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;

  const OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '🧠',
      title: 'Your Cognitive\nOperating System',
      subtitle: 'Think differently',
      description:
          'Thinkora is not a quiz app. It\'s a cognitive training platform that teaches you HOW TO THINK — developing logic, strategy, memory, creativity, and more.',
      accentColor: AppColors.logicRealm,
    ),
    OnboardingPage(
      emoji: '🗺️',
      title: 'Explore Cognitive\nWorlds',
      subtitle: 'Journey through realms',
      description:
          'Travel through 7 intellectual realms — Logic, Strategy, Memory, Math, Creativity, Innovation, and Mastermind. Each with 20 unique levels and boss challenges.',
      accentColor: AppColors.strategyRealm,
    ),
    OnboardingPage(
      emoji: '📈',
      title: 'Track Your\nThinkora Index',
      subtitle: 'Measure growth precisely',
      description:
          'Your TCI (Thinkora Cognitive Index) is a live rating of your cognitive abilities — across Logic, Memory, Focus, Strategy, Math, Creativity, and more.',
      accentColor: AppColors.memoryRealm,
    ),
    OnboardingPage(
      emoji: '⚔️',
      title: 'Battle Minds\nWorldwide',
      subtitle: 'Compete globally',
      description:
          'Challenge real players in Brain Battles, Logic Duels, and Puzzle Races. Climb global leaderboards and become the top cognitive athlete in your country.',
      accentColor: AppColors.creativityRealm,
    ),
    OnboardingPage(
      emoji: '🤖',
      title: 'Your Personal\nAI Coach',
      subtitle: 'Personalized intelligence',
      description:
          'Your AI Coach analyzes your performance, detects cognitive gaps, and builds a custom training plan — adapting in real-time to accelerate your growth.',
      accentColor: AppColors.innovationRealm,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.ageSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.ageSelection),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(page: page, index: index);
                },
              ),
            ),
            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _currentPage ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _pages[_currentPage].accentColor
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    onPressed: _nextPage,
                    gradient: LinearGradient(
                      colors: [
                        _pages[_currentPage].accentColor,
                        _pages[_currentPage].accentColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;
  final int index;

  const _OnboardingPageView({required this.page, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji with glow
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: page.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: page.accentColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 52),
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
          ),
          const SizedBox(height: 40),
          // Subtitle
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: page.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              page.subtitle.toUpperCase(),
              style: TextStyle(
                color: page.accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 14),
          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
              ),
          const SizedBox(height: 18),
          // Description
          Text(
            page.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
              ),
        ],
      ),
    );
  }
}
