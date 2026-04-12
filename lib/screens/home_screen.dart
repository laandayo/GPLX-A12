import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'chapter_list_screen.dart';
import 'question_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: _navIndex == 0
              ? _buildHomeContent(context, appProvider)
              : const StatisticsScreen(),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _navIndex,
            onTap: (index) => setState(() => _navIndex = index),
            activeColor: appProvider.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, AppProvider appProvider) {
    return SafeArea(
      child: Column(
        children: [
          // Top Section - Header
          _buildHeader(context, appProvider),

          // Middle Section - Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // License Type Toggle
                  LicenseTypeToggle(
                    selectedType: appProvider.selectedLicense,
                    onTypeChanged: appProvider.switchLicenseType,
                  ).animate().fadeIn(duration: 400.ms).slideY(),

                  const SizedBox(height: 12),

                  // Current study info
                  Text(
                    'Đang ôn thi ${appProvider.selectedLicense.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: appProvider.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // Menu Grid
                  _buildMenuGrid(context, appProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App logo and name
          const Row(
            children: [
              Icon(Icons.directions_car, size: 32),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GPLX',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ôn thi bằng lái',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Study stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Hôm nay: ${appProvider.questionsStudiedToday} câu',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '🔥 Streak: ${appProvider.streakDays} ngày',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, AppProvider appProvider) {
    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        final color = appProvider.primaryColor;
        final totalQuestions = appProvider.selectedLicense == LicenseType.a1
            ? 450
            : 400;
        final answeredCount = questionProvider.answeredCount;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            MenuGridItem(
              icon: '📝',
              title: 'Thi thử',
              subtitle: '3/10 đề',
              color: color,
              onTap: () => _startMockTest(context),
            ),
            MenuGridItem(
              icon: '📚',
              title: 'Ôn tập',
              subtitle: '$answeredCount/$totalQuestions câu',
              color: color,
              onTap: () => _navigateToChapters(context, StudyMode.all),
            ),
            MenuGridItem(
              icon: '🔖',
              title: 'Đánh dấu',
              subtitle: '${questionProvider.currentQuestions.where((q) => q.isMarked).length} câu',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.marked),
            ),
            MenuGridItem(
              icon: '❌',
              title: 'Sai',
              subtitle: '${questionProvider.wrongCount} câu',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.wrong),
            ),
            MenuGridItem(
              icon: '⚠️',
              title: 'Quan trọng',
              subtitle: '',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.important),
            ),
            MenuGridItem(
              icon: '🎲',
              title: 'Ngẫu nhiên',
              subtitle: '',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.random),
            ),
            MenuGridItem(
              icon: '✅',
              title: 'Chưa trả lời',
              subtitle: '',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.unanswered),
            ),
            MenuGridItem(
              icon: '🔄',
              title: 'Ôn lại câu sai',
              subtitle: '',
              color: color,
              onTap: () => _retryWrongQuestions(context),
            ),
            MenuGridItem(
              icon: '⏱️',
              title: 'Thi thật',
              subtitle: 'Có giờ',
              color: color,
              onTap: () => _startRealExam(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChapters(BuildContext context, StudyMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterListScreen(studyMode: mode),
      ),
    );
  }

  void _navigateToQuestions(BuildContext context, StudyMode mode) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();

    questionProvider.setStudyMode(mode);
    questionProvider.loadQuestions(appProvider.selectedLicense);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  void _startMockTest(BuildContext context) {
    // TODO: Implement mock test screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng thi thử đang được phát triển')),
    );
  }

  void _retryWrongQuestions(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();

    questionProvider.retryWrongQuestions(appProvider.selectedLicense);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu sai nào để ôn lại')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  void _startRealExam(BuildContext context) {
    // TODO: Implement real exam mode with timer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng thi thật đang được phát triển')),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _SettingsSheet(),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<QuestionProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text('Tự động chuyển câu'),
                subtitle: const Text('Sau khi trả lời'),
                value: provider.autoAdvance,
                onChanged: (_) => provider.toggleAutoAdvance(),
              );
            },
          ),
          Consumer<QuestionProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text('Hiện giải thích'),
                value: provider.showExplanation,
                onChanged: (_) => provider.toggleShowExplanation(),
              );
            },
          ),
        ],
      ),
    );
  }
}
