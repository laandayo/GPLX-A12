import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';

class StudyModeInfoScreen extends StatelessWidget {
  final StudyMode studyMode;

  const StudyModeInfoScreen({super.key, required this.studyMode});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final questions = _questions(type);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: Text(_title),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(_icon, size: 40, color: primary),
                            const SizedBox(height: 12),
                            Text(
                              _title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _description,
                              style: TextStyle(
                                fontSize: 15,
                                color: text.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _InfoCard(
                        icon: Icons.question_answer,
                        title: 'Số câu hỏi',
                        value: '${questions.length} câu',
                        color: primary,
                        isDark: isDark,
                      ),
                      if (studyMode == StudyMode.wrong) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Số lần sai theo từng câu',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: text,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...questions.take(8).map((question) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Câu ${question.id}',
                                            style: TextStyle(color: text),
                                          ),
                                        ),
                                        Text(
                                          '${question.wrongCount} lần sai',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.wrongColor(isDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              if (questions.length > 8)
                                Text(
                                  'Và ${questions.length - 8} câu khác',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: text.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.collections_bookmark,
                        title: 'Nguồn dữ liệu',
                        value: 'Lấy trực tiếp từ toàn bộ ngân hàng câu hỏi',
                        color: const Color(0xFF42A5F5),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.timer_outlined,
                        title: 'Thời gian',
                        value: 'Không giới hạn',
                        color: const Color(0xFFFFA000),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: questions.isEmpty ? null : () => _startSession(context),
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'BẮT ĐẦU ÔN',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Question> _questions(LicenseType type) {
    final repository = QuestionRepository();
    switch (studyMode) {
      case StudyMode.all:
        return repository.getQuestions(type);
      case StudyMode.unanswered:
        return repository.getUnansweredQuestions(type);
      case StudyMode.wrong:
        return repository.getWrongQuestions(type);
      case StudyMode.marked:
        return repository.getMarkedQuestions(type);
      case StudyMode.random:
      case StudyMode.important:
      case StudyMode.exam:
      case StudyMode.practice:
        return <Question>[];
    }
  }

  String get _title {
    switch (studyMode) {
      case StudyMode.all:
        return 'Ôn tất cả';
      case StudyMode.unanswered:
        return 'Chưa trả lời';
      case StudyMode.wrong:
        return 'Câu hay sai';
      case StudyMode.marked:
        return 'Đánh dấu';
      case StudyMode.random:
      case StudyMode.important:
      case StudyMode.exam:
      case StudyMode.practice:
        return 'Ôn tập';
    }
  }

  String get _description {
    switch (studyMode) {
      case StudyMode.all:
        return 'Làm toàn bộ câu hỏi hiện có trong ngân hàng dữ liệu.';
      case StudyMode.unanswered:
        return 'Chỉ gồm các câu bạn chưa từng trả lời lần nào.';
      case StudyMode.wrong:
        return 'Chỉ gồm các câu đang có chuỗi trả lời sai từ 2 lần trở lên.';
      case StudyMode.marked:
        return 'Chỉ gồm các câu bạn đã đánh dấu để xem lại.';
      case StudyMode.random:
      case StudyMode.important:
      case StudyMode.exam:
      case StudyMode.practice:
        return '';
    }
  }

  IconData get _icon {
    switch (studyMode) {
      case StudyMode.all:
        return Icons.menu_book;
      case StudyMode.unanswered:
        return Icons.help_outline;
      case StudyMode.wrong:
        return Icons.error_outline;
      case StudyMode.marked:
        return Icons.bookmark_outline;
      case StudyMode.random:
      case StudyMode.important:
      case StudyMode.exam:
      case StudyMode.practice:
        return Icons.school;
    }
  }

  void _startSession(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadFilteredQuestions(appProvider.selectedLicense, studyMode);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu hỏi nào trong mục này')),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
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
                  style: TextStyle(fontSize: 13, color: text.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
