import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../data/data.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, StatisticsProvider>(
      builder: (context, appProvider, statsProvider, child) {
        final color = appProvider.primaryColor;
        final licenseType = appProvider.selectedLicense;
        final accuracy = statsProvider.getOverallAccuracy(licenseType);
        final answered = statsProvider.getAnsweredCount(licenseType);
        final total = statsProvider.getTotalQuestions(licenseType);
        final passProb = statsProvider.getPassProbability(licenseType);

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Thống kê'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview cards
                _buildOverviewCards(
                  context,
                  color,
                  accuracy,
                  answered,
                  total,
                  passProb,
                ),

                const SizedBox(height: 24),

                // Chapter progress
                const Text(
                  'Tiến độ theo chương',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildChapterProgress(context, statsProvider, licenseType),

                const SizedBox(height: 24),

                // Study heatmap (placeholder)
                const Text(
                  'Hoạt động ôn tập (30 ngày)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStudyHeatmap(context, statsProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    Color color,
    double accuracy,
    int answered,
    int total,
    double passProb,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          icon: Icons.check_circle,
          title: 'Chính xác',
          value: '${(accuracy * 100).toStringAsFixed(1)}%',
          color: Colors.green,
        ),
        _StatCard(
          icon: Icons.question_answer,
          title: 'Đã trả lời',
          value: '$answered/$total',
          color: color,
        ),
        _StatCard(
          icon: Icons.trending_up,
          title: 'Tỉ lệ đậu',
          value: '${(passProb * 100).toStringAsFixed(1)}%',
          color: Colors.blue,
        ),
        _StatCard(
          icon: Icons.flag,
          title: 'Câu còn lại',
          value: '${total - answered}',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildChapterProgress(
    BuildContext context,
    StatisticsProvider statsProvider,
    LicenseType licenseType,
  ) {
    final chapterProgress = statsProvider.getChapterProgress(licenseType);
    final chapters = QuestionRepository().getChapters(licenseType);

    return Column(
      children: chapters.map((chapter) {
        final completed = chapterProgress[chapter.id] ?? 0;
        final total = chapter.questionIds.length;
        final progress = total > 0 ? completed / total : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(chapter.icon ?? '📖', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completed/$total câu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudyHeatmap(
    BuildContext context,
    StatisticsProvider statsProvider,
  ) {
    final heatmap = statsProvider.getStudyHeatmap();

    return Container(
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
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: heatmap.map((value) {
          Color color;
          switch (value) {
            case 0:
              color = Colors.grey[200]!;
              break;
            case 1:
              color = Colors.green[100]!;
              break;
            case 2:
              color = Colors.green[300]!;
              break;
            case 3:
              color = Colors.green[500]!;
              break;
            default:
              color = Colors.green[700]!;
          }

          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
