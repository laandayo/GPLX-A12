import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/exam_persistence_service.dart';
import '../data/data.dart';
import 'exam_info_screen.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final exams = QuestionRepository().getExams(appProvider.selectedLicense);
        final color = appProvider.primaryColor;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Danh sách đề thi'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: exams.length + 1, // +1 for random exam
            itemBuilder: (context, index) {
              if (index == exams.length) {
                // Random exam item
                return _RandomExamCard(color: color).animate().fadeIn(delay: (100 * index).ms);
              }

              final exam = exams[index];
              final attemptCount = ExamPersistenceService()
                  .getAttemptCount(appProvider.selectedLicense, exam.id);
              final bestScore = ExamPersistenceService()
                  .getBestScore(appProvider.selectedLicense, exam.id);

              return _ExamCard(
                exam: exam,
                attemptCount: attemptCount,
                bestScore: bestScore,
                color: color,
                onTap: () => _navigateToExamInfo(context, exam),
              ).animate().fadeIn(delay: (100 * index).ms);
            },
          ),
        );
      },
    );
  }

  void _navigateToExamInfo(BuildContext context, Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamInfoScreen(exam: exam),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final int attemptCount;
  final int? bestScore;
  final Color color;
  final VoidCallback onTap;

  const _ExamCard({
    required this.exam,
    required this.attemptCount,
    required this.bestScore,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAttempted = attemptCount > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Exam icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasAttempted
                      ? color.withAlpha(38)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${exam.id}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasAttempted ? color : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Exam name
              Text(
                exam.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Status
              if (hasAttempted) ...[
                Text(
                  'Lần: $attemptCount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                if (bestScore != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tốt nhất: $bestScore',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: bestScore! >= 23 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Chưa thi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RandomExamCard extends StatelessWidget {
  final Color color;

  const _RandomExamCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
      child: InkWell(
        onTap: () => _startRandomExam(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🎲',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Đề ngẫu nhiên',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRandomExam(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final questionProvider = context.read<QuestionProvider>();

    questionProvider.loadRandomExam(appProvider.selectedLicense);

    if (questionProvider.currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có đề thi nào')),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/question_screen');
  }
}
