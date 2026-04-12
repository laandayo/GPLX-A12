import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../data/data.dart';
import 'chapter_list_screen.dart';
import 'question_screen.dart';
import 'statistics_screen.dart';
import 'exam_list_screen.dart';
import 'question_catalog_screen.dart';
import 'settings_screen.dart';

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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
        color: Theme.of(context).cardColor,
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
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
        final totalQuestions = QuestionRepository().getTotalQuestions(appProvider.selectedLicense);
        final answeredCount = QuestionRepository().getAnsweredCount(appProvider.selectedLicense);
        final wrongCount = QuestionRepository().getWrongQuestions(appProvider.selectedLicense).length;
        final markedCount = QuestionRepository().getMarkedQuestions(appProvider.selectedLicense).length;
        final unansweredCount = QuestionRepository().getUnansweredQuestions(appProvider.selectedLicense).length;
        final importantCount = QuestionRepository().getImportantQuestions(appProvider.selectedLicense).length;

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
              subtitle: 'Chọn đề thi',
              color: color,
              onTap: () => _navigateToExamList(context),
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
              subtitle: '$markedCount câu',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.marked),
            ),
            MenuGridItem(
              icon: '❌',
              title: 'Sai',
              subtitle: '$wrongCount câu',
              color: color,
              onTap: () => _navigateToQuestions(context, StudyMode.wrong),
            ),
            MenuGridItem(
              icon: '⚠️',
              title: 'Quan trọng',
              subtitle: '$importantCount câu',
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
              subtitle: '$unansweredCount câu',
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
              icon: '📖',
              title: 'Danh sách câu hỏi',
              subtitle: 'Tra cứu nhanh',
              color: color,
              onTap: () => _navigateToCatalog(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateToExamList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExamListScreen()),
    );
  }

  void _navigateToCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionCatalogScreen()),
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

    questionProvider.loadFilteredQuestions(appProvider.selectedLicense, mode);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có câu hỏi nào trong mục này')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }

  void _retryWrongQuestions(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();

    questionProvider.loadFilteredQuestions(
      appProvider.selectedLicense,
      StudyMode.wrong,
    );

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

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
}
