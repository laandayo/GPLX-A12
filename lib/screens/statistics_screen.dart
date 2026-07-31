import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import '../widgets/responsive_content.dart';

class StatisticsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const StatisticsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, StatisticsProvider>(
      builder: (context, appProvider, statsProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final surface = AppColors.surface(type, isDark);
        final accuracy = statsProvider.getOverallAccuracy(type);
        final answered = statsProvider.getAnsweredCount(type);
        final total = statsProvider.getTotalQuestions(type);
        final passProb = statsProvider.getPassProbability(type);

        final heatmap = statsProvider.getStudyHeatmap(appProvider.studyActivity);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: const Text('Thống kê'),
            automaticallyImplyLeading: false,
            leading: (onBack != null || Navigator.of(context).canPop())
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  )
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(context, primary, text, surface, accuracy, answered, total, passProb),
                  const SizedBox(height: 24),
                  Text('Tiến độ theo chương',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 12),
                  _buildChapterProgress(context, statsProvider, type, primary, text, surface, isDark),
                  const SizedBox(height: 24),
                  Text('Hoạt động ôn tập (30 ngày)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
                  const SizedBox(height: 12),
                  _buildStudyHeatmap(context, heatmap, surface, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(BuildContext context, Color primary, Color text, Color surface,
      double accuracy, int answered, int total, double passProb) {
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 840 ? 4 : 2;
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3,
      children: [
        _StatCard(icon: Icons.check_circle, title: 'Chính xác',
          value: '${(accuracy * 100).toStringAsFixed(1)}%', color: AppColors.correctColor(Theme.of(context).brightness == Brightness.dark)),
        _StatCard(icon: Icons.question_answer, title: 'Đã trả lời',
          value: '$answered/$total', color: primary),
        _StatCard(icon: Icons.trending_up, title: 'Tỉ lệ đậu',
          value: '${(passProb * 100).toStringAsFixed(1)}%', color: const Color(0xFF42A5F5)),
        _StatCard(icon: Icons.flag, title: 'Câu còn lại',
          value: '${total - answered}', color: const Color(0xFFFFA000)),
      ],
    );
  }

  Widget _buildChapterProgress(BuildContext context, StatisticsProvider statsProvider,
      LicenseType type, Color primary, Color text, Color surface, bool isDark) {
    final chapters = QuestionRepository().getChapters(type);
    final questions = QuestionRepository().getQuestions(type);

    return Column(
      children: chapters.map((chapter) {
        final chapterQuestions = questions.where((q) => q.chapter == chapter.title).toList();
        final completed = chapterQuestions.where((q) => q.isAnswered).length;
        final total = chapterQuestions.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(chapter.icon ?? '📖', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapter.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('$completed/$total câu',
                          style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress, minHeight: 6,
                backgroundColor: AppColors.dividerColor(isDark),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudyHeatmap(BuildContext context, List<int> heatmap,
      Color surface, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Wrap(
        spacing: 4, runSpacing: 4,
        children: heatmap.map((value) {
          Color color;
          switch (value) {
            case 0: color = AppColors.dividerColor(isDark); break;
            case 1: color = isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9); break;
            case 2: color = isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784); break;
            case 3: color = isDark ? const Color(0xFF388E3C) : const Color(0xFF4CAF50); break;
            default: color = isDark ? const Color(0xFF43A047) : const Color(0xFF2E7D32);
          }
          return Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = AppColors.text(context.read<AppProvider>().selectedLicense, isDark);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.7))),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
