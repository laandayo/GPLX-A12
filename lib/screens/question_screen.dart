import 'dart:async';

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
  static const int _examDurationSeconds = 20 * 60;

  final ScrollController _scrollController = ScrollController();
  Timer? _examTimer;
  int _remainingSeconds = _examDurationSeconds;
  bool _fiveMinuteWarningShown = false;
  bool _oneMinuteWarningShown = false;

  @override
  void dispose() {
    _examTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, QuestionProvider>(
      builder: (context, appProvider, questionProvider, child) {
        _syncExamTimer(questionProvider);

        final question = questionProvider.currentQuestion;
        if (question == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Câu hỏi')),
            body: const Center(child: Text('Không có câu hỏi nào')),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final isGradeImmediately = !questionProvider.isExamMode ||
            questionProvider.scoringMode == ScoringMode.gradeImmediately;

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          body: Column(
            children: [
              _buildHeader(
                context,
                appProvider,
                questionProvider,
                question,
                primary,
                isDark,
              ),
              Expanded(
                child: _buildQuestionContent(
                  context,
                  appProvider,
                  questionProvider,
                  question,
                  primary,
                  isDark,
                  isGradeImmediately,
                ),
              ),
              _buildBottomNavigation(
                context,
                appProvider,
                questionProvider,
                primary,
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncExamTimer(QuestionProvider questionProvider) {
    if (!questionProvider.isExamMode) {
      _examTimer?.cancel();
      _examTimer = null;
      _remainingSeconds = _examDurationSeconds;
      _fiveMinuteWarningShown = false;
      _oneMinuteWarningShown = false;
      return;
    }

    if (!questionProvider.hasSubmittedSession &&
        questionProvider.currentIndex == 0 &&
        questionProvider.answeredCount == 0 &&
        _remainingSeconds != _examDurationSeconds &&
        _examTimer == null) {
      _remainingSeconds = _examDurationSeconds;
      _fiveMinuteWarningShown = false;
      _oneMinuteWarningShown = false;
    }

    if (_examTimer != null || questionProvider.hasSubmittedSession) {
      return;
    }

    if (_remainingSeconds < 0) {
      _remainingSeconds = 0;
    } else if (_remainingSeconds > _examDurationSeconds) {
      _remainingSeconds = _examDurationSeconds;
    }
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final provider = context.read<QuestionProvider>();
      if (!provider.isExamMode || provider.hasSubmittedSession) {
        timer.cancel();
        _examTimer = null;
        return;
      }

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _examTimer = null;
        _handleTimeUp();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds == 5 * 60 && !_fiveMinuteWarningShown) {
        _fiveMinuteWarningShown = true;
        _showTimeWarning('Còn 5 phút, hãy kiểm tra lại các câu chưa làm.');
      } else if (_remainingSeconds == 60 && !_oneMinuteWarningShown) {
        _oneMinuteWarningShown = true;
        _showTimeWarning('Còn 1 phút, bài thi sẽ được nộp tự động.');
      }
    });
  }

  Widget _buildHeader(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
    Question question,
    Color primary,
    bool isDark,
  ) {
    final type = appProvider.selectedLicense;
    final text = AppColors.text(type, isDark);
    final surface = AppColors.surface(type, isDark);
    final modeLabel = questionProvider.isExamMode ? 'Thi thử' : 'Ôn tập';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: text),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Câu ${questionProvider.currentIndex + 1} / ${questionProvider.totalQuestions}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        modeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: text.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    question.isMarked ? Icons.bookmark : Icons.bookmark_border,
                    color: question.isMarked
                        ? AppColors.bookmarkColor(isDark)
                        : text.withValues(alpha: 0.5),
                  ),
                  onPressed: () => questionProvider.toggleMark(appProvider.selectedLicense),
                ),
              ],
            ),
            if (questionProvider.isExamMode) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA000).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFA000).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFFFA000), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA000),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: questionProvider.progress,
              backgroundColor: AppColors.dividerColor(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
              minHeight: 6,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusChip(
                  icon: Icons.check_circle,
                  label: 'Đúng',
                  count: questionProvider.correctCount,
                  color: AppColors.correctColor(isDark),
                ),
                _buildStatusChip(
                  icon: Icons.cancel,
                  label: 'Sai',
                  count: questionProvider.wrongCount,
                  color: AppColors.wrongColor(isDark),
                ),
                _buildStatusChip(
                  icon: Icons.bookmark,
                  label: 'Đánh dấu',
                  count: questionProvider.currentQuestions.where((q) => q.isMarked).length,
                  color: AppColors.bookmarkColor(isDark),
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
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
    Color primary,
    bool isDark,
    bool isGradeImmediately,
  ) {
    final type = appProvider.selectedLicense;
    final surface = AppColors.surface(type, isDark);
    final shouldShowExplanation = question.isAnswered &&
        question.isEvaluated &&
        appProvider.showExplanation;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.image != null && question.image!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.dividerColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.image!,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, trace) => Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: AppColors.text(type, isDark).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found: ${question.image}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.text(type, isDark).withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            width: double.infinity,
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
            child: Text(
              question.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text(type, isDark),
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          ...List.generate(question.answers.length, (index) {
            return _buildAnswerOption(
              context,
              appProvider,
              questionProvider,
              question,
              index,
              primary,
              isDark,
              isGradeImmediately,
            ).animate().fadeIn(delay: (100 * index).ms).slideX();
          }),
          if (!isGradeImmediately && question.isAnswered && !question.isEvaluated) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Đáp án đã được lưu. Kết quả sẽ được chấm khi nộp bài.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text(type, isDark),
                ),
              ),
            ),
          ],
          if (shouldShowExplanation) ...[
            const SizedBox(height: 20),
            _buildExplanation(context, appProvider, question, primary, isDark),
          ],
          if (questionProvider.isExamMode &&
              questionProvider.currentIndex == questionProvider.totalQuestions - 1) ...[
            const SizedBox(height: 20),
            _buildSubmitExamButton(context, questionProvider, appProvider),
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
    Color primary,
    bool isDark,
    bool isGradeImmediately,
  ) {
    final type = appProvider.selectedLicense;
    final answer = question.answers[index];
    final isSelected = question.selectedAnswerIndex == index;
    final hasAnswered = question.isAnswered;
    final showFeedback = question.isEvaluated && (isGradeImmediately || questionProvider.hasSubmittedSession);
    final isCorrect = index == question.correctAnswer;
    final surface = AppColors.surface(type, isDark);
    final text = AppColors.text(type, isDark);

    Color? backgroundColor;
    Color? textColor;
    Color borderColor = AppColors.dividerColor(isDark);

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.correctColor(isDark).withValues(alpha: 0.1);
        borderColor = AppColors.correctColor(isDark);
        textColor = AppColors.correctColor(isDark);
      } else if (isSelected) {
        backgroundColor = AppColors.wrongColor(isDark).withValues(alpha: 0.1);
        borderColor = AppColors.wrongColor(isDark);
        textColor = AppColors.wrongColor(isDark);
      }
    } else if (isSelected) {
      backgroundColor = primary.withValues(alpha: 0.15);
      borderColor = primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasAnswered
              ? null
              : () => _handleAnswer(
                    questionProvider,
                    answerIndex: index,
                    appProvider: appProvider,
                    gradeImmediately: isGradeImmediately,
                  ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: showFeedback
                        ? (isCorrect
                            ? AppColors.correctColor(isDark)
                            : (isSelected
                                ? AppColors.wrongColor(isDark)
                                : AppColors.dividerColor(isDark)))
                        : (isSelected
                            ? primary
                            : primary.withValues(alpha: 0.15)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: showFeedback
                            ? (isCorrect || isSelected
                                ? Colors.white
                                : text.withValues(alpha: 0.7))
                            : (isSelected ? Colors.white : primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: showFeedback && (isCorrect || isSelected)
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: textColor ?? text,
                    ),
                  ),
                ),
                if (showFeedback) ...[
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Color(0xFF43A047))
                  else if (isSelected)
                    const Icon(Icons.cancel, color: Color(0xFFE53935)),
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
    Color primary,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: primary),
              const SizedBox(width: 8),
              Text(
                'Giải thích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.explanation,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.text(appProvider.selectedLicense, isDark),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSubmitExamButton(
    BuildContext context,
    QuestionProvider questionProvider,
    AppProvider appProvider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: questionProvider.hasSubmittedSession
            ? null
            : () => _showSubmitConfirmation(context, questionProvider, appProvider),
        icon: const Icon(Icons.check_circle),
        label: const Text('NỘP BÀI'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.correctColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    AppProvider appProvider,
    QuestionProvider questionProvider,
    Color primary,
    bool isDark,
  ) {
    final type = appProvider.selectedLicense;
    final surface = AppColors.surface(type, isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: questionProvider.hasPrevious ? questionProvider.previousQuestion : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Trước'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.view_list, color: primary),
              onPressed: () => _showQuestionList(context, questionProvider, primary, isDark),
              tooltip: 'Danh sách câu hỏi',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: questionProvider.hasNext ? questionProvider.nextQuestion : null,
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
    QuestionProvider questionProvider, {
    required int answerIndex,
    required AppProvider appProvider,
    required bool gradeImmediately,
  }) {
    questionProvider.selectAnswer(
      answerIndex,
      appProvider.selectedLicense,
      gradeImmediately: gradeImmediately,
    );
    appProvider.incrementQuestionsStudied();
  }

  void _showSubmitConfirmation(
    BuildContext context,
    QuestionProvider questionProvider,
    AppProvider appProvider,
  ) {
    final unanswered = questionProvider.currentQuestions.where((q) => !q.isAnswered).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface(type, isDark),
        title: Text('Nộp bài?', style: TextStyle(color: AppColors.text(type, isDark))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn đã trả lời ${questionProvider.answeredCount}/${questionProvider.totalQuestions} câu.',
              style: TextStyle(color: AppColors.text(type, isDark)),
            ),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Còn $unanswered câu chưa trả lời!',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _submitExam(context, questionProvider, appProvider);
            },
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }

  void _submitExam(
    BuildContext context,
    QuestionProvider questionProvider,
    AppProvider appProvider,
  ) {
    _examTimer?.cancel();
    _examTimer = null;
    final result = questionProvider.submitExam(appProvider.selectedLicense);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ExamResultDialog(
        result: result,
        onRetry: () {
          questionProvider.resetCurrentExam();
          setState(() {
            _remainingSeconds = _examDurationSeconds;
            _fiveMinuteWarningShown = false;
            _oneMinuteWarningShown = false;
          });
          Navigator.pop(dialogContext);
        },
      ),
    );
  }

  void _showQuestionList(
    BuildContext context,
    QuestionProvider questionProvider,
    Color primary,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        final type = context.read<AppProvider>().selectedLicense;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: AppColors.surface(type, isDark),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Danh sách câu hỏi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(type, isDark),
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
                    final isPending = question.isAnswered && !question.isEvaluated;
                    Color color;
                    if (isCurrent) {
                      color = primary;
                    } else if (question.isEvaluated && question.isCorrect) {
                      color = AppColors.correctColor(isDark);
                    } else if (question.isEvaluated) {
                      color = AppColors.wrongColor(isDark);
                    } else if (isPending) {
                      color = primary.withValues(alpha: 0.65);
                    } else if (question.isMarked) {
                      color = AppColors.bookmarkColor(isDark);
                    } else {
                      color = AppColors.dividerColor(isDark);
                    }
                    return Material(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          questionProvider.jumpToQuestion(index);
                          Navigator.pop(bottomSheetContext);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: (question.isAnswered || isCurrent || isPending)
                                  ? Colors.white
                                  : AppColors.text(type, isDark),
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
        );
      },
    );
  }

  void _showTimeWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _handleTimeUp() {
    if (!mounted) return;

    final questionProvider = context.read<QuestionProvider>();
    if (questionProvider.hasSubmittedSession) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hết giờ, bài thi đã được nộp tự động.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _submitExam(context, questionProvider, context.read<AppProvider>());
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}

class _ExamResultDialog extends StatelessWidget {
  final ExamResult result;
  final VoidCallback onRetry;

  const _ExamResultDialog({
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = context.read<AppProvider>().selectedLicense;
    final wrongQuestions = context
        .read<QuestionProvider>()
        .currentQuestions
        .where((q) => q.isEvaluated && !q.isCorrect)
        .toList();

    return AlertDialog(
      backgroundColor: AppColors.surface(type, isDark),
      title: Row(
        children: [
          Icon(
            result.passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: result.passed
                ? AppColors.bookmarkColor(isDark)
                : AppColors.wrongColor(isDark),
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            result.passed ? 'Chúc mừng!' : 'Chưa đạt',
            style: TextStyle(color: AppColors.text(type, isDark)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${result.correctAnswers}/${result.totalQuestions}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: result.passed
                  ? AppColors.correctColor(isDark)
                  : AppColors.wrongColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.passed ? 'Bạn đã vượt qua kỳ thi!' : 'Bạn cần 23/30 câu để đạt',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.text(type, isDark)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statColumn('Đúng', '${result.correctAnswers}', AppColors.correctColor(isDark)),
              _statColumn('Sai', '${result.wrongAnswers}', AppColors.wrongColor(isDark)),
              _statColumn(
                'Trống',
                '${result.unansweredQuestions}',
                isDark ? Colors.grey[500]! : Colors.grey,
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (wrongQuestions.isNotEmpty)
          TextButton(
            onPressed: () => _showWrongQuestions(context, wrongQuestions),
            child: const Text('Xem câu bị sai'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Xem lại bài'),
        ),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Làm lại'),
        ),
      ],
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showWrongQuestions(BuildContext context, List<Question> wrongQuestions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = context.read<AppProvider>().selectedLicense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          color: AppColors.surface(type, isDark),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Các câu bị sai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(type, isDark),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: wrongQuestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final question = wrongQuestions[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background(type, isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.wrongColor(isDark).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Câu ${question.id}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.wrongColor(isDark),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            question.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text(type, isDark),
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
        );
      },
    );
  }
}
