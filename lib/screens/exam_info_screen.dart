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
        final color = appProvider.primaryColor;
        final licenseType = appProvider.selectedLicense;
        final totalQuestions = exam.questionIds.length;
        final attemptCount = ExamPersistenceService()
            .getAttemptCount(licenseType, exam.id);
        final bestScore = ExamPersistenceService()
            .getBestScore(licenseType, exam.id);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                      // Top Section - Exam Title
                      _buildHeader(context, exam, licenseType),

                      const SizedBox(height: 32),

                      // Middle Section - Exam Details
                      _buildExamDetails(
                        context,
                        totalQuestions,
                        attemptCount,
                        bestScore,
                        color,
                      ),

                      const SizedBox(height: 24),

                      // Scoring Mode Selection
                      _buildScoringMode(context, questionProvider, color),
                    ],
                  ),
                ),
              ),

              // Bottom Section - Start Button
              _buildStartButton(context, questionProvider, appProvider, color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Exam exam,
    LicenseType licenseType,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            exam.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Giấy phép lái xe ${licenseType.name}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamDetails(
    BuildContext context,
    int totalQuestions,
    int attemptCount,
    int? bestScore,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin đề thi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Info cards
        _InfoCard(
          icon: Icons.question_answer,
          title: 'Số câu hỏi',
          value: '$totalQuestions câu',
          color: color,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.check_circle,
          title: 'Điểm đạt',
          value: '23/$totalQuestions',
          color: Colors.green,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.timer,
          title: 'Thời gian',
          value: 'Không giới hạn',
          color: Colors.orange,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        _InfoCard(
          icon: Icons.history,
          title: 'Số lần thi',
          value: '$attemptCount lần',
          color: Colors.blue,
          isDark: isDark,
        ),

        if (bestScore != null) ...[
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.emoji_events,
            title: 'Điểm tốt nhất',
            value: '$bestScore/$totalQuestions',
            color: bestScore >= 23 ? Colors.amber : Colors.red,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildScoringMode(
    BuildContext context,
    QuestionProvider questionProvider,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chế độ chấm điểm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Grade after submission
        _ScoringModeOption(
          icon: Icons.check_circle_outline,
          title: 'Chấm sau khi nộp bài',
          subtitle: 'Chỉ xem kết quả khi hoàn thành',
          isSelected: questionProvider.scoringMode == ScoringMode.gradeAfterSubmission,
          color: color,
          isDark: isDark,
          onTap: () => questionProvider.setScoringMode(ScoringMode.gradeAfterSubmission),
        ),
        const SizedBox(height: 12),

        // Grade immediately
        _ScoringModeOption(
          icon: Icons.flash_on,
          title: 'Chấm ngay sau mỗi câu',
          subtitle: 'Biết đúng/sai ngay lập tức',
          isSelected: questionProvider.scoringMode == ScoringMode.gradeImmediately,
          color: color,
          isDark: isDark,
          onTap: () => questionProvider.setScoringMode(ScoringMode.gradeImmediately),
        ),
      ],
    );
  }

  Widget _buildStartButton(
    BuildContext context,
    QuestionProvider questionProvider,
    AppProvider appProvider,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startExam(context, questionProvider, appProvider),
            icon: const Icon(Icons.play_arrow, size: 28),
            label: const Text(
              'BẮT ĐẦU THI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startExam(
    BuildContext context,
    QuestionProvider questionProvider,
    AppProvider appProvider,
  ) {
    questionProvider.loadExam(
      appProvider.selectedLicense,
      exam.id,
    );

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải đề thi')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
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
  final VoidCallback onTap;

  const _ScoringModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withAlpha(25)
            : (isDark ? Colors.grey[800] : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Colors.grey[300]!,
          width: 2,
        ),
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
                Icon(
                  icon,
                  color: isSelected ? color : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
