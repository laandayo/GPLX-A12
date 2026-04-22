import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/data.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../services/exam_persistence_service.dart';
import '../services/question_state_persistence.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final type = appProvider.selectedLicense;
        final primary = AppColors.primary(type, isDark);
        final text = AppColors.text(type, isDark);
        final surface = AppColors.surface(type, isDark);

        return Scaffold(
          backgroundColor: AppColors.background(type, isDark),
          appBar: AppBar(
            title: const Text('Cài đặt'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            children: [
              _buildSectionHeader(context, 'Giao diện', primary, text),
              _buildThemeOptions(
                context,
                appProvider,
                isDark,
                primary,
                text,
                surface,
              ),
              const Divider(height: 32),
              _buildSectionHeader(context, 'Cài đặt ôn tập', primary, text),
              _buildStudySettings(context, appProvider, isDark, primary, text),
              const Divider(height: 32),
              _buildSectionHeader(context, 'Dữ liệu', primary, text),
              _buildDataActions(context, appProvider, surface, text),
              const Divider(height: 32),
              _buildSectionHeader(context, 'Thông tin', primary, text),
              _buildAbout(context, isDark, primary, text, surface),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataActions(
    BuildContext context,
    AppProvider appProvider,
    Color surface,
    Color text,
  ) {
    return Material(
      color: surface,
      child: ListTile(
        leading: const Icon(
          Icons.delete_forever_outlined,
          color: Color(0xFFD32F2F),
        ),
        title: const Text('Xóa dữ liệu'),
        subtitle: Text(
          'Đưa ứng dụng về trạng thái ban đầu',
          style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.6)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: text.withValues(alpha: 0.5),
        ),
        onTap: () => _confirmResetData(context, appProvider),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color primary,
    Color text,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),
    );
  }

  Widget _buildThemeOptions(
    BuildContext context,
    AppProvider appProvider,
    bool isDark,
    Color primary,
    Color text,
    Color surface,
  ) {
    return Column(
      children: ThemeModeOption.values.map((mode) {
        final isSelected = appProvider.themeMode == mode;
        return Material(
          color: surface,
          child: InkWell(
            onTap: () => appProvider.setThemeMode(mode),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    mode.icon,
                    color: isSelected ? primary : text.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      mode.displayName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? primary : text,
                      ),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle, color: primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudySettings(
    BuildContext context,
    AppProvider appProvider,
    bool isDark,
    Color primary,
    Color text,
  ) {
    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(
            Icons.auto_awesome,
            color: text.withValues(alpha: 0.7),
          ),
          title: const Text('Tự động chuyển câu'),
          subtitle: Text(
            appProvider.autoAdvance
                ? 'Tự động chuyển câu sau khi trả lời'
                : 'Chuyển câu thủ công',
            style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.5)),
          ),
          value: appProvider.autoAdvance,
          activeThumbColor: primary,
          onChanged: (_) => appProvider.toggleAutoAdvance(),
        ),
        SwitchListTile(
          secondary: Icon(Icons.lightbulb, color: text.withValues(alpha: 0.7)),
          title: const Text('Hiện giải thích'),
          subtitle: Text(
            appProvider.showExplanation
                ? 'Hiển thị giải thích sau khi trả lời'
                : 'Ẩn giải thích',
            style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.5)),
          ),
          value: appProvider.showExplanation,
          activeThumbColor: primary,
          onChanged: (value) => appProvider.setShowExplanation(value),
        ),
      ],
    );
  }

  Widget _buildAbout(
    BuildContext context,
    bool isDark,
    Color primary,
    Color text,
    Color surface,
  ) {
    return Column(
      children: [
        Material(
          color: surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 16),
                const Text('Phiên bản'),
                const Spacer(),
                Text(
                  '0.2.6',
                  style: TextStyle(color: text.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
        Material(
          color: surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.description),
                const SizedBox(width: 16),
                const Text('GPLX - Ôn thi bằng lái'),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: text.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmResetData(
    BuildContext context,
    AppProvider appProvider,
  ) async {
    final questionProvider = context.read<QuestionProvider>();
    final statisticsProvider = context.read<StatisticsProvider>();
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text(
          'Lịch sử làm bài, thống kê, đánh dấu, câu sai và cài đặt sẽ bị xóa. Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await QuestionStatePersistence().clearAllStatesForAllLicenses();
    await ExamPersistenceService().clearAllAttempts();
    QuestionRepository().resetAllProgress();
    questionProvider.resetState();
    statisticsProvider.clearHistory();
    await appProvider.resetAppData();

    if (!context.mounted) {
      return;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}
