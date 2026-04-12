import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';

enum CatalogFilter { all, marked, wrong, unanswered, important }

extension CatalogFilterExtension on CatalogFilter {
  String get displayName {
    switch (this) {
      case CatalogFilter.all: return 'Tất cả';
      case CatalogFilter.marked: return 'Đánh dấu';
      case CatalogFilter.wrong: return 'Câu sai';
      case CatalogFilter.unanswered: return 'Chưa trả lời';
      case CatalogFilter.important: return 'Quan trọng';
    }
  }

  IconData get icon {
    switch (this) {
      case CatalogFilter.all: return Icons.list;
      case CatalogFilter.marked: return Icons.bookmark;
      case CatalogFilter.wrong: return Icons.error;
      case CatalogFilter.unanswered: return Icons.help_outline;
      case CatalogFilter.important: return Icons.warning;
    }
  }
}

class QuestionCatalogScreen extends StatefulWidget {
  const QuestionCatalogScreen({super.key});

  @override
  State<QuestionCatalogScreen> createState() => _QuestionCatalogScreenState();
}

class _QuestionCatalogScreenState extends State<QuestionCatalogScreen> {
  CatalogFilter _filter = CatalogFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final surface = AppColors.surface(type, isDark);
        final questions = _getFilteredQuestions(type);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: const Text('Danh sách câu hỏi'),
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context)),
          ),
          body: Column(
            children: [
              _buildSearchBar(context, primary, text, surface, isDark),
              _buildFilterChips(context, primary, text, isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('${questions.length} câu hỏi',
                  style: TextStyle(fontSize: 14, color: text.withValues(alpha: 0.7))),
              ),
              Expanded(
                child: questions.isEmpty
                    ? _buildEmptyState(context, text)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return _QuestionCatalogItem(
                            question: question, color: primary, text: text,
                            isDark: isDark, surface: surface,
                            onTap: () => _navigateToQuestion(context, question, appProvider),
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

  Widget _buildSearchBar(BuildContext context, Color primary, Color text, Color surface, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm trong nội dung câu hỏi...',
          prefixIcon: Icon(Icons.search, color: text.withValues(alpha: 0.5)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear),
                  onPressed: () { setState(() { _searchController.clear(); _searchQuery = ''; }); })
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primary, width: 2)),
        ),
        style: TextStyle(color: text),
        onChanged: (value) {
          setState(() { _searchQuery = value; });
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, Color primary, Color text, bool isDark) {
    return Container(
      height: 50, padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: CatalogFilter.values.map((filter) {
          final isSelected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.displayName),
              selected: isSelected,
              avatar: Icon(filter.icon, size: 18),
              onSelected: (_) => setState(() => _filter = filter),
              selectedColor: primary.withValues(alpha: 0.15),
              checkmarkColor: primary,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Question> _getFilteredQuestions(LicenseType type) {
    List<Question> questions;
    switch (_filter) {
      case CatalogFilter.all: questions = QuestionRepository().getQuestions(type); break;
      case CatalogFilter.marked: questions = QuestionRepository().getMarkedQuestions(type); break;
      case CatalogFilter.wrong: questions = QuestionRepository().getWrongQuestions(type); break;
      case CatalogFilter.unanswered: questions = QuestionRepository().getUnansweredQuestions(type); break;
      case CatalogFilter.important: questions = QuestionRepository().getImportantQuestions(type); break;
    }
    // Apply text search filter
    if (_searchQuery.trim().isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase().trim();
      questions = questions.where((q) =>
          q.content.toLowerCase().contains(lowerQuery)).toList();
    }
    return questions;
  }

  Widget _buildEmptyState(BuildContext context, Color text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: text.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Không tìm thấy câu hỏi nào',
            style: TextStyle(fontSize: 18, color: text.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  void _navigateToQuestion(BuildContext context, Question question, AppProvider appProvider) {
    final questionProvider = context.read<QuestionProvider>();
    questionProvider.loadAllQuestionsForCatalog(appProvider.selectedLicense);
    final index = questionProvider.currentQuestions.indexWhere((q) => q.id == question.id);
    if (index != -1) questionProvider.jumpToQuestion(index);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
  }
}

class _QuestionCatalogItem extends StatelessWidget {
  final Question question;
  final Color color;
  final Color text;
  final bool isDark;
  final Color surface;
  final VoidCallback onTap;

  const _QuestionCatalogItem({
    required this.question, required this.color, required this.text,
    required this.isDark, required this.surface, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
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
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text('${question.id}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.content,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(question.chapter,
                              style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.5)),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                          if (question.isImportant)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.wrongColor(isDark).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4)),
                              child: Text('Quan trọng',
                                style: TextStyle(fontSize: 10, color: AppColors.wrongColor(isDark),
                                  fontWeight: FontWeight.w600))),
                          if (question.isMarked)
                            Icon(Icons.bookmark, size: 16, color: AppColors.bookmarkColor(isDark)),
                          if (question.status == QuestionStatus.wrong)
                            Icon(Icons.error, size: 16, color: AppColors.wrongColor(isDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: text.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
