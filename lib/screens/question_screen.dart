import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, QuestionProvider>(
      builder: (context, appProvider, questionProvider, child) {
        final question = questionProvider.currentQuestion;

        if (question == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Câu hỏi')),
            body: const Center(
              child: Text('Không có câu hỏi nào'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // Top Section - Header with progress
              _buildHeader(context, appProvider, questionProvider, question),

              // Middle Section - Question content
              Expanded(
                child: _buildQuestionContent(
                  context,
                  appProvider,
                  questionProvider,
                  question,
                ),
              ),

              // Bottom Section - Navigation
              _buildBottomNavigation(context, appProvider, questionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
    Question question,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Question counter and bookmark
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Câu ${questionProvider.currentIndex + 1} / ${questionProvider.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    question.isMarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: question.isMarked
                        ? appProvider.primaryColor
                        : Colors.grey,
                  ),
                  onPressed: questionProvider.toggleMark,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress bar
            LinearProgressIndicator(
              value: questionProvider.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                appProvider.primaryColor,
              ),
              minHeight: 6,
            ),

            const SizedBox(height: 12),

            // Status indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusChip(
                  icon: Icons.check_circle,
                  label: 'Đúng',
                  count: questionProvider.correctCount,
                  color: Colors.green,
                ),
                _buildStatusChip(
                  icon: Icons.cancel,
                  label: 'Sai',
                  count: questionProvider.wrongCount,
                  color: Colors.red,
                ),
                _buildStatusChip(
                  icon: Icons.bookmark,
                  label: 'Đánh dấu',
                  count: questionProvider.currentQuestions
                      .where((q) => q.isMarked)
                      .length,
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
    Question question,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question image (if exists)
          if (question.image != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              question.content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Answer options
          ...List.generate(question.answers.length, (index) {
            return _buildAnswerOption(
              context,
              appProvider,
              questionProvider,
              question,
              index,
            ).animate().fadeIn(delay: (100 * index).ms).slideX();
          }),

          // Explanation (shown after answering)
          if (question.isAnswered && questionProvider.showExplanation) ...[
            const SizedBox(height: 20),
            _buildExplanation(context, appProvider, question),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
    Question question,
    int index,
  ) {
    final answer = question.answers[index];
    final isSelected = question.selectedAnswerIndex == index;
    final isCorrect = answer.isCorrect;
    final hasAnswered = question.isAnswered;

    Color? backgroundColor;
    Color? textColor;
    Color borderColor = Colors.grey[300]!;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
        textColor = Colors.green[700];
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red[50];
        borderColor = Colors.red;
        textColor = Colors.red[700];
      }
    } else if (isSelected) {
      backgroundColor = appProvider.primaryColor.withAlpha(38);
      borderColor = appProvider.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered ? null : () => _handleAnswer(questionProvider, question, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Answer letter
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: hasAnswered
                        ? (isCorrect
                            ? Colors.green
                            : (isSelected ? Colors.red : Colors.grey[200]))
                        : appProvider.primaryColor.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasAnswered
                            ? (isCorrect
                                ? Colors.white
                                : (isSelected ? Colors.white : Colors.grey[700]))
                            : appProvider.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Answer content
                Expanded(
                  child: Text(
                    answer.content,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasAnswered && (isCorrect || isSelected)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                ),

                // Status icon
                if (hasAnswered) ...[
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (isSelected)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(
    BuildContext context,
    AppProvider appProvider,
    Question question,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appProvider.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appProvider.primaryColor.withAlpha(76),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: appProvider.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Giải thích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appProvider.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: questionProvider.hasPrevious
                    ? questionProvider.previousQuestion
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Trước'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Question list button
            IconButton(
              icon: const Icon(Icons.view_list),
              onPressed: () => _showQuestionList(context, questionProvider),
              tooltip: 'Danh sách câu hỏi',
            ),

            const SizedBox(width: 12),

            // Next button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: questionProvider.hasNext
                    ? questionProvider.nextQuestion
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Sau'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAnswer(
    QuestionProvider questionProvider,
    Question question,
    int answerIndex,
  ) {
    questionProvider.selectAnswer(answerIndex);
    context.read<AppProvider>().incrementQuestionsStudied();

    // Auto advance if enabled
    if (questionProvider.autoAdvance && questionProvider.hasNext) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          questionProvider.nextQuestion();
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _showQuestionList(
    BuildContext context,
    QuestionProvider questionProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Danh sách câu hỏi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: questionProvider.totalQuestions,
                itemBuilder: (context, index) {
                  final question = questionProvider.currentQuestions[index];
                  final isCurrent = index == questionProvider.currentIndex;

                  Color color;
                  if (isCurrent) {
                    color = context.read<AppProvider>().primaryColor;
                  } else if (question.isCorrect) {
                    color = Colors.green;
                  } else if (question.isAnswered) {
                    color = Colors.red;
                  } else if (question.isMarked) {
                    color = Colors.orange;
                  } else {
                    color = Colors.grey[300]!;
                  }

                  return Material(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        questionProvider.jumpToQuestion(index);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: question.isAnswered || isCurrent
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
