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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          body: _navIndex == 0
              ? _buildHomeContent(context, appProvider)
              : const StatisticsScreen(),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _navIndex,
            onTap: (index) => setState(() => _navIndex = index),
            activeColor: AppColors.primary(type, isDark),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, appProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LicenseTypeToggle(
                    selectedType: appProvider.selectedLicense,
                    onTypeChanged: appProvider.switchLicenseType,
                  ).animate().fadeIn(duration: 400.ms).slideY(),
                  const SizedBox(height: 12),
                  Text(
                    'Đang ôn thi ${appProvider.selectedLicense.displayName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final text = AppColors.text(type, isDark);
    final surface = AppColors.surface(type, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Image.asset('assets/logo1.png', width: 32, height: 32),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ứng Dụng Ôn Luyện',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  Text(
                    'Trường Cao đẳng Kỹ thuật Công - Nông nghiệp Quảng Trị',
                    style: TextStyle(
                      fontSize: 11,
                      color: text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Hôm nay: ${appProvider.questionsStudiedToday} câu',
                style: TextStyle(
                  fontSize: 12,
                  color: text.withValues(alpha: 0.5),
                ),
              ),
              Text(
                '🔥 Streak: ${appProvider.streakDays} ngày',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: text.withValues(alpha: 0.7),
            ),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);

    return Consumer<QuestionProvider>(
      builder: (context, questionProvider, child) {
        final totalQuestions = QuestionRepository().getTotalQuestions(type);
        final answeredCount = QuestionRepository().getAnsweredCount(type);
        final wrongCount = QuestionRepository().getWrongQuestions(type).length;
        final markedCount = QuestionRepository()
            .getMarkedQuestions(type)
            .length;
        final unansweredCount = QuestionRepository()
            .getUnansweredQuestions(type)
            .length;
        final importantCount = QuestionRepository()
            .getImportantQuestions(type)
            .length;

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
              color: primary,
              onTap: () => _navigateToExamList(context),
            ),
            MenuGridItem(
              icon: '📚',
              title: 'Ôn tập',
              subtitle: '$answeredCount/$totalQuestions câu',
              color: primary,
              onTap: () => _navigateToChapters(context, StudyMode.all),
            ),
            MenuGridItem(
              icon: '🔖',
              title: 'Đánh dấu',
              subtitle: '$markedCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.marked),
            ),
            MenuGridItem(
              icon: '❌',
              title: 'Sai',
              subtitle: '$wrongCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.wrong),
            ),
            MenuGridItem(
              icon: '⚠️',
              title: 'Quan trọng',
              subtitle: '$importantCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.important),
            ),
            MenuGridItem(
              icon: '🎲',
              title: 'Ngẫu nhiên',
              subtitle: '',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.random),
            ),
            MenuGridItem(
              icon: '✅',
              title: 'Chưa trả lời',
              subtitle: '$unansweredCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.unanswered),
            ),
            MenuGridItem(
              icon: '🔄',
              title: 'Ôn lại câu sai',
              subtitle: '',
              color: primary,
              onTap: () => _retryWrongQuestions(context),
            ),
            MenuGridItem(
              icon: '📖',
              title: 'Danh sách câu hỏi',
              subtitle: 'Tra cứu nhanh',
              color: primary,
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
      MaterialPageRoute(builder: (_) => ChapterListScreen(studyMode: mode)),
    );
  }

  void _navigateToQuestions(BuildContext context, StudyMode mode) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadFilteredQuestions(appProvider.selectedLicense, mode);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu hỏi nào trong mục này')),
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
