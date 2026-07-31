import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class WindowsKeyboardHelpScreen extends StatelessWidget {
  const WindowsKeyboardHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = appProvider.selectedLicense;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);

    return Scaffold(
      backgroundColor: AppColors.background(type, isDark),
      appBar: AppBar(title: const Text('Phím tắt bàn phím')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Làm đề nhanh hơn trên máy tính Windows.',
            style: TextStyle(color: text.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          _ShortcutCard(
            title: 'Khi đang làm bài',
            primary: primary,
            shortcuts: const [
              ('← / A', 'Câu trước'),
              ('→ / D', 'Câu sau'),
              ('1 / 2 / 3 / 4', 'Chọn đáp án A / B / C / D'),
              ('↑ / W hoặc ↓ / S', 'Mở hoặc đóng danh sách câu hỏi'),
              ('Enter', 'Sang câu tiếp theo hoặc nộp bài ở câu cuối'),
              ('Esc', 'Quay lại / rời bài thi'),
            ],
          ),
          const SizedBox(height: 12),
          _ShortcutCard(
            title: 'Ở các màn hình khác',
            primary: primary,
            shortcuts: const [
              ('← / ↑ / A / W', 'Chuyển đến nút hoặc mục trước'),
              ('→ / ↓ / D / S', 'Chuyển đến nút hoặc mục sau'),
              ('Enter', 'Kích hoạt nút hoặc mục đang chọn'),
              ('Esc', 'Quay lại'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String title;
  final Color primary;
  final List<(String, String)> shortcuts;

  const _ShortcutCard({
    required this.title,
    required this.primary,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).colorScheme.onSurface;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: primary),
            ),
            const SizedBox(height: 12),
            for (final shortcut in shortcuts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        shortcut.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(shortcut.$2, style: TextStyle(color: text)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
