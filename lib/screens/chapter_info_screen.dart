import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';

class ChapterInfoScreen extends StatelessWidget {
  final Chapter chapter;

  const ChapterInfoScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final questions = QuestionRepository().getQuestionsByChapter(type, chapter.title);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: Text(chapter.title),
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
                            Text(chapter.icon ?? '📖', style: const TextStyle(fontSize: 42)),
                            const SizedBox(height: 12),
                            Text(
                              chapter.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chapter.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: text.withValues(alpha: 0.7),
                              ),
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
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.timer_outlined,
                        title: 'Thời gian',
                        value: 'Không giới hạn',
                        color: const Color(0xFFFFA000),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.school_outlined,
                        title: 'Hình thức',
                        value: 'Ôn tập theo chương',
                        color: const Color(0xFF42A5F5),
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

  void _startSession(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadQuestionsByChapter(appProvider.selectedLicense, chapter.title);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu hỏi trong chương này')),
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
