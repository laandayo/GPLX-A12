import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ads/ads.dart';
import '../data/data.dart';
import '../providers/providers.dart';
import '../services/exam_persistence_service.dart';
import 'home_screen.dart';

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  late Future<void> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      AdsBootstrap.initialize(),
      QuestionRepository().initializeAsync(),
      ExamPersistenceService().initializeAll(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _StartupErrorView(
              onRetry: () => setState(() => _startupFuture = _initializeApp()),
            );
          }
          return const HomeScreen();
        }

        return const _StartupLoadingView();
      },
    );
  }
}

class _StartupLoadingView extends StatelessWidget {
  const _StartupLoadingView();

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final type = appProvider.selectedLicense;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(type, isDark),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo2.png', width: 96, height: 96),
            const SizedBox(height: 20),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary(type, isDark),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tối ưu dữ liệu ứng dụng...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final type = appProvider.selectedLicense;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(type, isDark),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.primary(type, isDark),
              ),
              const SizedBox(height: 16),
              Text(
                'Không thể khởi tạo dữ liệu ứng dụng.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
