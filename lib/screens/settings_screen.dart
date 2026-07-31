import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final sidePadding = ((constraints.maxWidth - 840) / 2)
                  .clamp(0, double.infinity)
                  .toDouble();
              return ListView(
                padding: EdgeInsets.symmetric(horizontal: sidePadding),
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
                  const SizedBox(height: 8),
                  _buildPaletteOptions(
                    appProvider,
                    isDark,
                    primary,
                    text,
                    surface,
                  ),
                  const SizedBox(height: 8),
                  _buildTextSizeOptions(appProvider, primary, text, surface),
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Cài đặt ôn tập', primary, text),
                  _buildStudySettings(
                    context,
                    appProvider,
                    isDark,
                    primary,
                    text,
                  ),
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Dữ liệu', primary, text),
                  _buildDataActions(context, appProvider, surface, text),
                  if (kIsWeb) _buildWebStorageNotice(surface, text),
                  if (!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.windows) ...[
                    const Divider(height: 32),
                    _buildSectionHeader(context, 'Windows', primary, text),
                    _buildWindowsKeyboardHelp(context, surface, text),
                  ],
                  const Divider(height: 32),
                  _buildSectionHeader(context, 'Thông tin', primary, text),
                  _buildAbout(context, isDark, primary, text, surface),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWindowsKeyboardHelp(
    BuildContext context,
    Color surface,
    Color text,
  ) {
    return Material(
      color: surface,
      child: ListTile(
        leading: const Icon(Icons.keyboard_outlined),
        title: const Text('Phím tắt bàn phím'),
        subtitle: Text(
          'Xem cách điều khiển ứng dụng bằng bàn phím',
          style: TextStyle(fontSize: 12, color: text.withValues(alpha: 0.6)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: text.withValues(alpha: 0.5),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WindowsKeyboardHelpScreen()),
        ),
      ),
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

  Widget _buildWebStorageNotice(Color surface, Color text) {
    return Material(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.devices_outlined, color: text.withValues(alpha: 0.65)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Dữ liệu ôn tập được lưu trên thiết bị và trình duyệt này. Dữ liệu có thể mất khi bạn xóa dữ liệu trang web hoặc gỡ ứng dụng khỏi Màn hình chính.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: text.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildPaletteOptions(
    AppProvider appProvider,
    bool isDark,
    Color primary,
    Color text,
    Color surface,
  ) {
    return Material(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Màu chủ đạo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppThemePalette.values.map((palette) {
                final previous = AppColors.activePalette;
                AppColors.activePalette = palette;
                final color = AppColors.primary(
                  appProvider.selectedLicense,
                  isDark,
                );
                AppColors.activePalette = previous;
                final isSelected = appProvider.themePalette == palette;

                return InkWell(
                  onTap: () => appProvider.setThemePalette(palette),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : text.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(palette.icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          palette.displayName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? color : text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeOptions(
    AppProvider appProvider,
    Color primary,
    Color text,
    Color surface,
  ) {
    return Material(
      color: surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kích cỡ chữ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: text.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<AppTextSizeOption>(
              segments: AppTextSizeOption.values
                  .map(
                    (size) => ButtonSegment<AppTextSizeOption>(
                      value: size,
                      label: Text(size.displayName),
                    ),
                  )
                  .toList(growable: false),
              selected: {appProvider.textSize},
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) =>
                      states.contains(WidgetState.selected) ? primary : text,
                ),
              ),
              onSelectionChanged: (selection) {
                appProvider.setTextSize(selection.first);
              },
            ),
          ],
        ),
      ),
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
                ? 'Chỉ áp dụng khi không chấm đúng/sai ngay'
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
                  'v1.0.0 Release',
                  style: TextStyle(color: text.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
        Material(
          color: surface,
          child: InkWell(
            onTap: () => _showAppExplanationDialog(context, text, primary),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.help_outline),
                  const SizedBox(width: 16),
                  const Text('Về ứng dụng'),
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
        ),
        Material(
          color: surface,
          child: InkWell(
            onTap: () => _showCreditsDialog(context, text, primary),
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
        ),
      ],
    );
  }

  void _showAppExplanationDialog(
    BuildContext context,
    Color text,
    Color primary,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Giải thích về cách tính của những mục ở Trang thống kê:',
                style: TextStyle(color: text),
              ),
              const SizedBox(height: 12),
              _buildInfoBullet(
                'Tỉ lệ chính xác',
                'Là tỷ lệ phần trăm của tổng số lần trả lời đúng trên tổng số lần trả lời.',
              ),
              const SizedBox(height: 10),
              _buildInfoBullet(
                'Tỉ lệ đậu',
                'Tỉ lệ đậu hiện tại được tính theo Độ chính xác x 0.9, tức là 90% của chỉ số “Chính xác”.',
              ),
              const SizedBox(height: 10),
              _buildInfoBullet(
                'Hoạt động ôn tập (30 ngày)',
                'Hoạt động ôn tập (30 ngày) hiển thị mức độ hoạt động theo 30 ngày vừa qua dựa trên số lần học/ngày, được quy về 4 mức cường độ.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Đóng', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }

  void _showCreditsDialog(BuildContext context, Color text, Color primary) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Credits'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Làm bằng cả trái tim đến từ đội ngũ thuộc ',
                style: TextStyle(color: text),
              ),
              const SizedBox(height: 12),
              Text(
                'Trường Cao Đẳng Kỹ Thuật Công - Nông nghiệp Quảng Trị',
                style: TextStyle(color: text),
              ),
              const SizedBox(height: 18),
              Center(
                child: Image.asset(
                  'assets/logo1.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Đóng', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 13)),
            ],
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
