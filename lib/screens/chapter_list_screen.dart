import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final StudyMode studyMode;

  const ChapterListScreen({
    super.key,
    this.studyMode = StudyMode.all,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, QuestionProvider>(
      builder: (context, appProvider, questionProvider, child) {
        final chapters = QuestionRepository().getChapters(appProvider.selectedLicense);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Chọn chương'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Study mode options
              if (studyMode == StudyMode.all) ...[
                _buildStudyModeOptions(context, appProvider, questionProvider),
              ],

              // Chapter list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return _ChapterCard(
                      chapter: chapter,
                      onTap: () => _navigateToChapter(context, chapter),
                    ).animate().fadeIn(delay: (100 * index).ms).slideX();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudyModeOptions(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
  ) {
    final color = appProvider.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn chế độ ôn tập',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StudyModeButton(
                  icon: Icons.book,
                  label: 'Ôn tất cả',
                  onTap: () => questionProvider.setStudyMode(StudyMode.all),
                  isSelected: questionProvider.studyMode == StudyMode.all,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StudyModeButton(
                  icon: Icons.help_outline,
                  label: 'Chưa trả lời',
                  onTap: () => questionProvider.setStudyMode(StudyMode.unanswered),
                  isSelected: questionProvider.studyMode == StudyMode.unanswered,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StudyModeButton(
                  icon: Icons.error_outline,
                  label: 'Câu sai',
                  onTap: () => questionProvider.setStudyMode(StudyMode.wrong),
                  isSelected: questionProvider.studyMode == StudyMode.wrong,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StudyModeButton(
                  icon: Icons.bookmark_outline,
                  label: 'Đánh dấu',
                  onTap: () => questionProvider.setStudyMode(StudyMode.marked),
                  isSelected: questionProvider.studyMode == StudyMode.marked,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(BuildContext context, Chapter chapter) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();

    questionProvider.loadQuestionsByChapter(
      appProvider.selectedLicense,
      chapter.title,
    );

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có câu hỏi trong chương này')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionScreen(),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.read<AppProvider>().primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      chapter.icon ?? '📖',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                ),
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

  const _StudyModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : Theme.of(context).colorScheme.outline.withAlpha(76),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : color,
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
