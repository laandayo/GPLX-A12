import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';
import 'question_screen.dart';

enum CatalogFilter {
  all,
  marked,
  wrong,
  unanswered,
  important,
}

extension CatalogFilterExtension on CatalogFilter {
  String get name {
    switch (this) {
      case CatalogFilter.all:
        return 'Tất cả';
      case CatalogFilter.marked:
        return 'Đánh dấu';
      case CatalogFilter.wrong:
        return 'Câu sai';
      case CatalogFilter.unanswered:
        return 'Chưa trả lời';
      case CatalogFilter.important:
        return 'Quan trọng';
    }
  }

  IconData get icon {
    switch (this) {
      case CatalogFilter.all:
        return Icons.list;
      case CatalogFilter.marked:
        return Icons.bookmark;
      case CatalogFilter.wrong:
        return Icons.error;
      case CatalogFilter.unanswered:
        return Icons.help_outline;
      case CatalogFilter.important:
        return Icons.warning;
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
  int? _searchedId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final questions = _getFilteredQuestions(appProvider.selectedLicense);
        final color = appProvider.primaryColor;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Danh sách câu hỏi'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Search bar
              _buildSearchBar(context, color),

              // Filter chips
              _buildFilterChips(context, color),

              // Question count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${questions.length} câu hỏi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                      ),
                    ),
                    if (_searchedId != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchedId = null;
                            _searchController.clear();
                          });
                        },
                        child: const Text('Xóa tìm kiếm'),
                      ),
                  ],
                ),
              ),

              // Question list
              Expanded(
                child: questions.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return _QuestionCatalogItem(
                            question: question,
                            color: color,
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

  Widget _buildSearchBar(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo ID câu hỏi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchedId = null;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            if (value.isEmpty) {
              _searchedId = null;
            } else {
              _searchedId = int.tryParse(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, Color color) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: CatalogFilter.values.map((filter) {
          final isSelected = _filter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.name),
              selected: isSelected,
              avatar: Icon(filter.icon, size: 18),
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
              selectedColor: color.withAlpha(38),
              checkmarkColor: color,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Question> _getFilteredQuestions(LicenseType type) {
    List<Question> questions;

    // First apply filter
    switch (_filter) {
      case CatalogFilter.all:
        questions = QuestionRepository().getQuestions(type);
        break;
      case CatalogFilter.marked:
        questions = QuestionRepository().getMarkedQuestions(type);
        break;
      case CatalogFilter.wrong:
        questions = QuestionRepository().getWrongQuestions(type);
        break;
      case CatalogFilter.unanswered:
        questions = QuestionRepository().getUnansweredQuestions(type);
        break;
      case CatalogFilter.important:
        questions = QuestionRepository().getImportantQuestions(type);
        break;
    }

    // Then apply search filter
    if (_searchedId != null) {
      try {
        final found = questions.firstWhere((q) => q.id == _searchedId);
        return [found];
      } catch (e) {
        return [];
      }
    }

    return questions;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(76),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy câu hỏi nào',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQuestion(
    BuildContext context,
    Question question,
    AppProvider appProvider,
  ) {
    final questionProvider = context.read<QuestionProvider>();

    // Load all questions and jump to the selected one
    questionProvider.loadAllQuestionsForCatalog(appProvider.selectedLicense);

    // Find the index of the selected question
    final index = questionProvider.currentQuestions.indexWhere((q) => q.id == question.id);
    if (index != -1) {
      questionProvider.jumpToQuestion(index);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionScreen()),
    );
  }
}

class _QuestionCatalogItem extends StatelessWidget {
  final Question question;
  final Color color;
  final VoidCallback onTap;

  const _QuestionCatalogItem({
    required this.question,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(38),
          width: 1,
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
                // Question number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${question.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Question content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.content,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            question.chapter,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                            ),
                          ),
                          const Spacer(),
                          if (question.isImportant)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(38),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Quan trọng',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (question.isMarked) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.bookmark,
                              size: 16,
                              color: Colors.orange,
                            ),
                          ],
                          if (question.status == QuestionStatus.wrong) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.error,
                              size: 16,
                              color: Colors.red,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
