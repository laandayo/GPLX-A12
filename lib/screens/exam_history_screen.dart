import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/exam_persistence_service.dart';

class ExamHistoryScreen extends StatelessWidget {
  const ExamHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final type = appProvider.selectedLicense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);
    final attempts = ExamPersistenceService().getAllAttempts();

    return Scaffold(
      backgroundColor: AppColors.background(type, isDark),
      appBar: AppBar(
        title: const Text('Lịch sử làm bài'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: attempts.isEmpty
          ? Center(
              child: Text(
                'Chưa có bài thi nào được nộp',
                style: TextStyle(color: text.withValues(alpha: 0.7)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return _HistoryCard(
                  attempt: attempt,
                  primary: primary,
                  isDark: isDark,
                  onTap: () => _showAttemptDetails(context, attempt),
                );
              },
            ),
    );
  }

  void _showAttemptDetails(BuildContext context, ExamAttemptRecord attempt) {
    final appProvider = context.read<AppProvider>();
    final type = appProvider.selectedLicense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        color: AppColors.surface(type, isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attempt.examName ?? 'Bài thi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDateTime(attempt.completedAt ?? attempt.date)} • Hoàn thành trong ${_formatDuration(attempt.durationSeconds)}',
                    style: TextStyle(color: text.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SummaryPill(
                        label: 'Điểm',
                        value: '${attempt.score}/${attempt.totalQuestions}',
                        color: primary,
                      ),
                      const SizedBox(width: 8),
                      _SummaryPill(
                        label: 'Đúng',
                        value: '${attempt.correctAnswers}',
                        color: AppColors.correctColor(isDark),
                      ),
                      const SizedBox(width: 8),
                      _SummaryPill(
                        label: 'Sai',
                        value: '${attempt.wrongAnswers}',
                        color: AppColors.wrongColor(isDark),
                      ),
                      if (attempt.unansweredQuestions > 0) ...[
                        const SizedBox(width: 8),
                        _SummaryPill(
                          label: 'Trống',
                          value: '${attempt.unansweredQuestions}',
                          color: text.withValues(alpha: 0.55),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.dividerColor(isDark)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: attempt.questionDetails.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final detail = attempt.questionDetails[index];
                  final color = detail.isCorrect
                      ? AppColors.correctColor(isDark)
                      : AppColors.wrongColor(isDark);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Câu ${detail.questionId}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                            if (detail.isImportant) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppColors.wrongColor(isDark),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: text),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn chọn: ${detail.selectedAnswer ?? 'Chưa chọn'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: text.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đáp án đúng: ${detail.correctAnswer}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.correctColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ExamAttemptRecord attempt;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.attempt,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = context.read<AppProvider>().selectedLicense;
    final text = AppColors.text(type, isDark);
    final resultColor = attempt.passed
        ? AppColors.correctColor(isDark)
        : AppColors.wrongColor(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface(type, isDark),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    attempt.passed ? Icons.check_circle : Icons.cancel,
                    color: resultColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attempt.examName ?? 'Bài thi',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Làm vào ${_formatDateTime(attempt.completedAt ?? attempt.date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: text.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đúng ${attempt.correctAnswers} • Sai ${attempt.wrongAnswers} • Hoàn thành trong ${_formatDuration(attempt.durationSeconds)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: text.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${attempt.score}/${attempt.totalQuestions}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _formatDuration(int? seconds) {
  if (seconds == null) return 'Không rõ thời lượng';
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  if (minutes == 0) return '$remainingSeconds giây';
  return '$minutes phút ${remainingSeconds.toString().padLeft(2, '0')} giây';
}
