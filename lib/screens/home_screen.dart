import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../data/data.dart';
import 'chapter_list_screen.dart';
import 'question_screen.dart';
import 'statistics_screen.dart';
import 'exam_list_screen.dart';
import 'question_catalog_screen.dart';
import 'settings_screen.dart';
import 'exam_history_screen.dart';

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

        final isWideLayout = MediaQuery.sizeOf(context).width >= 840;
        final content = _navIndex == 0
            ? _buildHomeContent(context, appProvider)
            : const StatisticsScreen();

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          body: isWideLayout
              ? Row(
                  children: [
                    CustomNavigationRail(
                      currentIndex: _navIndex,
                      onTap: (index) => setState(() => _navIndex = index),
                      activeColor: AppColors.primary(type, isDark),
                    ),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: isWideLayout
              ? null
              : CustomBottomNavBar(
                  currentIndex: _navIndex,
                  onTap: (index) => setState(() => _navIndex = index),
                  activeColor: AppColors.primary(type, isDark),
                ),
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, AppProvider appProvider) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, appProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      _buildStudyProgressCard(
                        context,
                        appProvider,
                      ).animate().fadeIn(duration: 400.ms).slideY(),
                      if (kIsWeb) ...[
                        const SizedBox(height: 16),
                        _buildPwaInstallHint(context, appProvider),
                      ],
                      const SizedBox(height: 20),
                      _buildMenuGrid(context, appProvider),
                    ],
                  ),
                ),
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
                    'Ôn Luyện GPLX A1 & A',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  Text(
                    'Trường Cao đẳng Kỹ thuật',
                    style: TextStyle(
                      fontSize: 11,
                      color: text.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    'Công - Nông nghiệp Quảng Trị',
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

  Widget _buildStudyProgressCard(
    BuildContext context,
    AppProvider appProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);
    final surface = AppColors.surface(type, isDark);
    final totalQuestions = QuestionRepository().getTotalQuestions(type);
    final answeredCount = QuestionRepository().getAnsweredCount(type);
    final progress = totalQuestions == 0
        ? 0.0
        : (answeredCount / totalQuestions).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đang ôn GPLX',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$answeredCount/$totalQuestions câu • $percent%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: text.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Streak ${appProvider.streakDays} ngày',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPwaInstallHint(BuildContext context, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.add_to_home_screen_outlined, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cài đặt trên iPhone hoặc iPad',
                  style: TextStyle(fontWeight: FontWeight.w700, color: text),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Mở bằng Safari, chạm '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            CupertinoIcons.share,
                            size: 17,
                            color: text.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' rồi chọn “Thêm vào Màn hình chính” để dùng như ứng dụng.',
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: text.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
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

        final width = MediaQuery.sizeOf(context).width;
        final crossAxisCount = width >= 840
            ? 4
            : width >= 600
            ? 3
            : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width >= 600 ? 1.0 : 0.9,
          children: [
            MenuGridItem(
              icon: '📝',
              title: 'Thi thử',
              subtitle: 'Thi theo đề',
              color: primary,
              onTap: () => _navigateToExamList(context),
            ),
            MenuGridItem(
              icon: '📚',
              title: 'Ôn tập theo chương',
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
              title: 'Câu hay sai',
              subtitle: '$wrongCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.wrong),
            ),
            MenuGridItem(
              icon: '⚠️',
              title: 'Câu điểm liệt',
              subtitle: '$importantCount câu',
              color: primary,
              onTap: () => _navigateToQuestions(context, StudyMode.important),
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
            MenuGridItem(
              icon: '🕘',
              title: 'Lịch sử làm bài',
              subtitle: 'Các bài đã nộp',
              color: primary,
              onTap: () => _navigateToExamHistory(context),
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

  void _navigateToExamHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
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
