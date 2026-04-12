import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/exam_persistence_service.dart';
import 'question_screen.dart';

class ExamInfoScreen extends StatelessWidget {
  final Exam exam;
  const ExamInfoScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, QuestionProvider>(
      builder: (context, appProvider, questionProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final totalQuestions = exam.questionIds.length;
        final attemptCount = ExamPersistenceService().getAttemptCount(type, exam.id);
        final bestScore = ExamPersistenceService().getBestScore(type, exam.id);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: Text(exam.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, exam, type, primary, text, isDark),
                      const SizedBox(height: 32),
                      _buildExamDetails(context, totalQuestions, attemptCount, bestScore, primary, text, isDark),
                      const SizedBox(height: 24),
                      _buildScoringMode(context, questionProvider, primary, text, isDark),
                    ],
                  ),
                ),
              ),
              _buildStartButton(context, questionProvider, appProvider, primary, text),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Exam exam, LicenseType type,
      Color primary, Color text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(exam.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 8),
          Text('Giấy phép lái xe ${type.displayName}',
            style: TextStyle(fontSize: 16, color: text.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildExamDetails(BuildContext context, int totalQuestions,
      int attemptCount, int? bestScore, Color primary, Color text, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin đề thi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 16),
        _InfoCard(icon: Icons.question_answer, title: 'Số câu hỏi',
          value: '$totalQuestions câu', color: primary, isDark: isDark),
        const SizedBox(height: 12),
        _InfoCard(icon: Icons.check_circle, title: 'Điểm đạt',
          value: '23/$totalQuestions', color: AppColors.correctColor(isDark), isDark: isDark),
        const SizedBox(height: 12),
        _InfoCard(icon: Icons.timer, title: 'Thời gian',
          value: 'Không giới hạn', color: const Color(0xFFFFA000), isDark: isDark),
        const SizedBox(height: 12),
        _InfoCard(icon: Icons.history, title: 'Số lần thi',
          value: '$attemptCount lần', color: const Color(0xFF42A5F5), isDark: isDark),
        if (bestScore != null) ...[
          const SizedBox(height: 12),
          _InfoCard(icon: Icons.emoji_events, title: 'Điểm tốt nhất',
            value: '$bestScore/$totalQuestions',
            color: bestScore >= 23 ? AppColors.correctColor(isDark) : AppColors.wrongColor(isDark),
            isDark: isDark),
        ],
      ],
    );
  }

  Widget _buildScoringMode(BuildContext context, QuestionProvider questionProvider,
      Color primary, Color text, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chế độ chấm điểm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
        const SizedBox(height: 16),
        _ScoringModeOption(
          icon: Icons.check_circle_outline, title: 'Chấm sau khi nộp bài',
          subtitle: 'Chỉ xem kết quả khi hoàn thành',
          isSelected: questionProvider.scoringMode == ScoringMode.gradeAfterSubmission,
          color: primary, isDark: isDark, text: text,
          onTap: () => questionProvider.setScoringMode(ScoringMode.gradeAfterSubmission),
        ),
        const SizedBox(height: 12),
        _ScoringModeOption(
          icon: Icons.flash_on, title: 'Chấm ngay sau mỗi câu',
          subtitle: 'Biết đúng/sai ngay lập tức',
          isSelected: questionProvider.scoringMode == ScoringMode.gradeImmediately,
          color: primary, isDark: isDark, text: text,
          onTap: () => questionProvider.setScoringMode(ScoringMode.gradeImmediately),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, QuestionProvider questionProvider,
      AppProvider appProvider, Color primary, Color text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startExam(context, questionProvider, appProvider),
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text('BẮT ĐẦU THI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  void _startExam(BuildContext context, QuestionProvider questionProvider, AppProvider appProvider) {
    questionProvider.loadExam(appProvider.selectedLicense, exam.id);
    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải đề thi')));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoCard({required this.icon, required this.title, required this.value,
    required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final type = context.read<AppProvider>().selectedLicense;
    final text = AppColors.text(type, isDark);
    final surface = AppColors.surface(type, isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: text.withValues(alpha: 0.7))),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoringModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final Color text;
  final VoidCallback onTap;

  const _ScoringModeOption({
    required this.icon, required this.title, required this.subtitle,
    required this.isSelected, required this.color, required this.isDark,
    required this.text, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = context.read<AppProvider>().selectedLicense;
    final surface = AppColors.surface(type, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? color : AppColors.dividerColor(isDark), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? color : text.withValues(alpha: 0.7), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: isSelected ? color : text)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                        style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
