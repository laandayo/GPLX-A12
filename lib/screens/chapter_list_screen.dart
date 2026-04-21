import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';
import 'study_mode_info_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final StudyMode studyMode;
  const ChapterListScreen({super.key, this.studyMode = StudyMode.all});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, QuestionProvider>(
      builder: (context, appProvider, questionProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final chapters = QuestionRepository().getChapters(type);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: const Text('Chọn chương'),
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          ),
          body: Column(
            children: [
              if (studyMode == StudyMode.all)
                _buildStudyModeOptions(context, appProvider, questionProvider, primary, isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return _ChapterCard(chapter: chapter, primary: primary,
                      isDark: isDark, onTap: () => _navigateToChapter(context, chapter)).animate().fadeIn(delay: (100 * index).ms).slideX();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudyModeOptions(BuildContext context, AppProvider appProvider,
      QuestionProvider questionProvider, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chọn chế độ ôn tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StudyModeButton(icon: Icons.book, label: 'Ôn tất cả',
                onTap: () => _openStudyModeInfo(context, questionProvider, StudyMode.all),
                isSelected: questionProvider.studyMode == StudyMode.all, color: primary, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: _StudyModeButton(icon: Icons.help_outline, label: 'Chưa trả lời',
                onTap: () => _openStudyModeInfo(context, questionProvider, StudyMode.unanswered),
                isSelected: questionProvider.studyMode == StudyMode.unanswered, color: primary, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StudyModeButton(icon: Icons.error_outline, label: 'Câu hay sai',
                onTap: () => _openStudyModeInfo(context, questionProvider, StudyMode.wrong),
                isSelected: questionProvider.studyMode == StudyMode.wrong, color: primary, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: _StudyModeButton(icon: Icons.bookmark_outline, label: 'Đánh dấu',
                onTap: () => _openStudyModeInfo(context, questionProvider, StudyMode.marked),
                isSelected: questionProvider.studyMode == StudyMode.marked, color: primary, isDark: isDark)),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(BuildContext context, Chapter chapter) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadQuestionsByChapter(appProvider.selectedLicense, chapter.title);
    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có câu hỏi trong chương này')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
  }

  void _openStudyModeInfo(
    BuildContext context,
    QuestionProvider questionProvider,
    StudyMode mode,
  ) {
    questionProvider.setStudyMode(mode);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudyModeInfoScreen(studyMode: mode)),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  final Color primary;
  final bool isDark;

  const _ChapterCard({required this.chapter, required this.onTap, required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(context.read<AppProvider>().selectedLicense, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(chapter.icon ?? '📖', style: const TextStyle(fontSize: 28)))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(chapter.description,
                        style: TextStyle(fontSize: 13, color: text.withValues(alpha: 0.7)),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 18, color: text.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color color;
  final bool isDark;

  const _StudyModeButton({required this.icon, required this.label, required this.onTap,
    required this.isSelected, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? color : AppColors.dividerColor(isDark), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? Colors.white : color, size: 24),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
