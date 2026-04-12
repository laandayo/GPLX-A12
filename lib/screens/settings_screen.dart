import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Cài đặt'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            children: [
              // Theme Section
              _buildSectionHeader(context, 'Giao diện'),
              _buildThemeOptions(context, appProvider, isDark),

              const Divider(height: 32),

              // Study Settings Section
              _buildSectionHeader(context, 'Cài đặt ôn tập'),
              _buildStudySettings(context, appProvider, isDark),

              const Divider(height: 32),

              // About Section
              _buildSectionHeader(context, 'Thông tin'),
              _buildAbout(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeOptions(
    BuildContext context,
    AppProvider appProvider,
    bool isDark,
  ) {
    return Column(
      children: ThemeModeOption.values.map((mode) {
        final isSelected = appProvider.themeMode == mode;
        return _SettingsTile(
          leading: Icon(
            mode.icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withAlpha(178),
          ),
          title: Text(
            mode.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          isDark: isDark,
          onTap: () => appProvider.setThemeMode(mode),
        );
      }).toList(),
    );
  }

  Widget _buildStudySettings(
    BuildContext context,
    AppProvider appProvider,
    bool isDark,
  ) {
    return Column(
      children: [
        SwitchListTile(
          secondary: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
          ),
          title: const Text('Tự động chuyển câu'),
          subtitle: Text(
            appProvider.autoAdvance
                ? 'Tự động chuyển câu sau khi trả lời'
                : 'Chuyển câu thủ công',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
            ),
          ),
          value: appProvider.autoAdvance,
          onChanged: (_) => appProvider.toggleAutoAdvance(),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.lightbulb,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
          ),
          title: const Text('Hiện giải thích'),
          subtitle: Text(
            appProvider.showExplanation
                ? 'Hiển thị giải thích sau khi trả lời'
                : 'Ẩn giải thích',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
            ),
          ),
          value: appProvider.showExplanation,
          onChanged: (value) => appProvider.setShowExplanation(value),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.flash_on,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
          ),
          title: const Text('Chấm điểm ngay'),
          subtitle: Text(
            appProvider.gradeImmediately
                ? 'Biết đúng/sai sau mỗi câu trả lời'
                : 'Chấm điểm sau khi nộp bài',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
            ),
          ),
          value: appProvider.gradeImmediately,
          onChanged: (value) => appProvider.setGradeImmediately(value),
        ),
      ],
    );
  }

  Widget _buildAbout(BuildContext context, bool isDark) {
    return Column(
      children: [
        _SettingsTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Phiên bản'),
          trailing: Text(
            '0.0.2',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
            ),
          ),
          isDark: isDark,
          onTap: () {},
        ),
        _SettingsTile(
          leading: const Icon(Icons.description),
          title: const Text('GPLX - Ôn thi bằng lái'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.leading,
    required this.title,
    this.trailing,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.grey[800] : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle.merge(
                      child: title,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
