import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../data/data.dart';
import '../utils/web_user_agent.dart';
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
  static const _androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.gplx.xemay';
  static const _releaseRepository = String.fromEnvironment(
    'GPLX_RELEASE_REPOSITORY',
    defaultValue: 'laandayo/GPLX-A12',
  );
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
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 1100;
                      return Column(
                        children: [
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildStudyProgressCard(
                                    context,
                                    appProvider,
                                  ).animate().fadeIn(duration: 400.ms).slideY(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildDesktopStudyTip(
                                    context,
                                    appProvider,
                                  ).animate().fadeIn(duration: 500.ms),
                                ),
                              ],
                            )
                          else
                            _buildStudyProgressCard(
                              context,
                              appProvider,
                            ).animate().fadeIn(duration: 400.ms).slideY(),
                          if (kIsWeb) ...[
                            const SizedBox(height: 16),
                            _buildWebPlatformHint(context, appProvider),
                          ],
                          const SizedBox(height: 20),
                          _buildMenuGrid(context, appProvider),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStudyTip(BuildContext context, AppProvider appProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);
    final surface = AppColors.surface(type, isDark);
    final unanswered = QuestionRepository().getUnansweredQuestions(type).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: primary),
              const SizedBox(width: 8),
              Text(
                'Gợi ý hôm nay',
                style: TextStyle(fontWeight: FontWeight.w800, color: text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            unanswered > 0
                ? 'Bạn còn $unanswered câu chưa trả lời. Ôn một chương hoặc làm thử một đề để tiếp tục.'
                : 'Bạn đã trả lời toàn bộ câu hỏi. Hãy làm thử một đề để kiểm tra kiến thức.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: text.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _navigateToExamList(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Làm đề ngay'),
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

  Widget _buildWebPlatformHint(BuildContext context, AppProvider appProvider) {
    final userAgent = browserUserAgent;
    final isAndroid =
        userAgent.contains('android') ||
        defaultTargetPlatform == TargetPlatform.android;
    final isWindows =
        userAgent.contains('windows nt') ||
        defaultTargetPlatform == TargetPlatform.windows;

    if (isAndroid) {
      return _buildNativeDownloadHint(
        context,
        appProvider,
        title: 'Tải ứng dụng Android',
        description:
            'Cài ứng dụng từ Google Play hoặc tải bản APK mới nhất cho Android.',
        buttonLabel: 'Tải APK mới nhất',
        icon: Icons.android,
        assetName: 'GPLX-Android.apk',
        playStoreUrl: _androidPlayStoreUrl,
      );
    }
    if (isWindows) {
      return _buildNativeDownloadHint(
        context,
        appProvider,
        title: 'Tải phần mềm Windows',
        description: 'Tải installer mới nhất cho Windows 10 hoặc Windows 11.',
        buttonLabel: 'Tải bản Windows mới nhất',
        icon: Icons.desktop_windows_outlined,
        assetName: 'GPLX-Windows-x64-Setup.exe',
      );
    }
    return _buildPwaInstallHint(context, appProvider);
  }

  Widget _buildNativeDownloadHint(
    BuildContext context,
    AppProvider appProvider, {
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required String assetName,
    String? playStoreUrl,
  }) {
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
          Icon(icon, color: primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, color: text),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: text.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (playStoreUrl != null)
                      FilledButton.icon(
                        onPressed: () => _openExternalUrl(
                          context,
                          playStoreUrl,
                          errorMessage: 'Không thể mở Google Play.',
                        ),
                        icon: const Icon(Icons.shop_outlined),
                        label: const Text('Mở trong Play Store'),
                      ),
                    if (playStoreUrl != null)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _downloadLatestRelease(context, assetName),
                        icon: const Icon(Icons.download),
                        label: Text(buttonLabel),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () =>
                            _downloadLatestRelease(context, assetName),
                        icon: const Icon(Icons.download),
                        label: Text(buttonLabel),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadLatestRelease(
    BuildContext context,
    String assetName,
  ) async {
    final url =
        'https://github.com/$_releaseRepository/releases/latest/download/$assetName';
    await _openExternalUrl(
      context,
      url,
      errorMessage: 'Không thể mở đường dẫn tải xuống.',
    );
  }

  Future<void> _openExternalUrl(
    BuildContext context,
    String url, {
    required String errorMessage,
  }) async {
    final uri = Uri.parse(url);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        final crossAxisCount = width >= 1180
            ? 5
            : width >= 840
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
          childAspectRatio: width >= 1180
              ? 1.15
              : width >= 600
              ? 1.0
              : 0.9,
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
