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

        final activity = statsProvider.getStudyActivity(
          appProvider.studyActivity,
        );

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
                  _buildOverviewCards(
                    context,
                    primary,
                    text,
                    surface,
                    accuracy,
                    answered,
                    total,
                    passProb,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tiến độ theo chương',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChapterProgress(
                    context,
                    statsProvider,
                    type,
                    primary,
                    text,
                    surface,
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hoạt động 30 ngày qua',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStudyHeatmap(
                    context,
                    activity,
                    appProvider.streakDays,
                    surface,
                    text,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    Color primary,
    Color text,
    Color surface,
    double accuracy,
    int answered,
    int total,
    double passProb,
  ) {
    final crossAxisCount = MediaQuery.sizeOf(context).width >= 840 ? 4 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          icon: Icons.check_circle,
          title: 'Chính xác',
          value: '${(accuracy * 100).toStringAsFixed(1)}%',
          color: AppColors.correctColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        _StatCard(
          icon: Icons.question_answer,
          title: 'Đã trả lời',
          value: '$answered/$total',
          color: primary,
        ),
        _StatCard(
          icon: Icons.trending_up,
          title: 'Tỉ lệ đậu',
          value: '${(passProb * 100).toStringAsFixed(1)}%',
          color: const Color(0xFF42A5F5),
        ),
        _StatCard(
          icon: Icons.flag,
          title: 'Câu còn lại',
          value: '${total - answered}',
          color: const Color(0xFFFFA000),
        ),
      ],
    );
  }

  Widget _buildChapterProgress(
    BuildContext context,
    StatisticsProvider statsProvider,
    LicenseType type,
    Color primary,
    Color text,
    Color surface,
    bool isDark,
  ) {
    final chapters = QuestionRepository().getChapters(type);
    final questions = QuestionRepository().getQuestions(type);

    return Column(
      children: chapters.map((chapter) {
        final chapterQuestions = questions
            .where((q) => q.chapter == chapter.title)
            .toList();
        final completed = chapterQuestions.where((q) => q.isAnswered).length;
        final total = chapterQuestions.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    chapter.icon ?? '📖',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completed/$total câu',
                          style: TextStyle(
                            fontSize: 12,
                            color: text.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.dividerColor(isDark),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudyHeatmap(
    BuildContext context,
    List<StudyActivityDay> activity,
    int streakDays,
    Color surface,
    Color text,
    bool isDark,
  ) {
    final todayCount = activity.isEmpty ? 0 : activity.last.questionCount;
    final activeDays = activity.where((day) => day.questionCount > 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số câu đã ôn mỗi ngày',
            style: TextStyle(color: text.withValues(alpha: 0.7), height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _ActivitySummary(label: 'Hôm nay', value: '$todayCount câu'),
              _ActivitySummary(label: 'Có học', value: '$activeDays/30 ngày'),
              _ActivitySummary(label: 'Chuỗi học', value: '$streakDays ngày'),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 600) {
                return _buildWideActivityChart(context, activity, isDark, text);
              }
              return Column(
                children: [
                  for (
                    var rowStart = 0;
                    rowStart < activity.length;
                    rowStart += 10
                  )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildActivityRow(
                        context,
                        activity
                            .skip(rowStart)
                            .take(10)
                            .toList(growable: false),
                        isDark,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Số câu:',
                style: TextStyle(
                  fontSize: 11,
                  color: text.withValues(alpha: 0.65),
                ),
              ),
              for (final item in const [
                (0, '0'),
                (1, '1–10'),
                (2, '11–20'),
                (3, '21–40'),
                (4, '40+'),
              ])
                _ActivityLegend(
                  color: _activityColor(item.$1, isDark),
                  label: item.$2,
                ),
            ],
          ),
          if (activeDays == 0) ...[
            const SizedBox(height: 14),
            Text(
              'Hãy hoàn thành một câu hỏi để bắt đầu ghi nhận hoạt động.',
              style: TextStyle(
                fontSize: 12,
                color: text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    BuildContext context,
    List<StudyActivityDay> days,
    bool isDark,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            '${days.first.date.day}/${days.first.date.month}',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
        for (final day in days) ...[
          _buildActivityCell(context, day, isDark),
          if (day != days.last) const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _buildWideActivityChart(
    BuildContext context,
    List<StudyActivityDay> activity,
    bool isDark,
    Color text,
  ) {
    String dateLabel(StudyActivityDay day) =>
        '${day.date.day}/${day.date.month}';

    return Column(
      children: [
        Row(
          children: [
            for (final day in activity)
              Expanded(
                child: Center(child: _buildActivityCell(context, day, isDark)),
              ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              dateLabel(activity.first),
              style: TextStyle(
                fontSize: 10,
                color: text.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Text(
              dateLabel(activity[9]),
              style: TextStyle(
                fontSize: 10,
                color: text.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Text(
              dateLabel(activity[19]),
              style: TextStyle(
                fontSize: 10,
                color: text.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Text(
              '${dateLabel(activity.last)} · Hôm nay',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: text.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCell(
    BuildContext context,
    StudyActivityDay day,
    bool isDark,
  ) {
    final now = DateTime.now();
    final isToday =
        day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day;
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message:
          '${day.date.day}/${day.date.month}/${day.date.year} – Đã ôn ${day.questionCount} câu',
      child: Semantics(
        label:
            'Ngày ${day.date.day} tháng ${day.date.month}, đã ôn ${day.questionCount} câu',
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _activityColor(
              StatisticsProvider.activityLevel(day.questionCount),
              isDark,
            ),
            borderRadius: BorderRadius.circular(4),
            border: isToday
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  static Color _activityColor(int level, bool isDark) => switch (level) {
    0 => AppColors.dividerColor(isDark),
    1 => isDark ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
    2 => isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784),
    3 => isDark ? const Color(0xFF43A047) : const Color(0xFF4CAF50),
    _ => isDark ? const Color(0xFF66BB6A) : const Color(0xFF1B5E20),
  };
}

class _ActivitySummary extends StatelessWidget {
  final String label;
  final String value;

  const _ActivitySummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '$label: ',
      children: [
        TextSpan(
          text: value,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
    style: TextStyle(
      fontSize: 13,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

class _ActivityLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ActivityLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = AppColors.text(
      context.read<AppProvider>().selectedLicense,
      isDark,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: text.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
