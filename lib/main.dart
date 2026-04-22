import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GplxApp());
}

class GplxApp extends StatelessWidget {
  const GplxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider()..initialize(context),
        ),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: _GplxAppContent(),
    );
  }
}

class _GplxAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GPLX - Ôn thi bằng lái',
          theme: appProvider.lightTheme,
          darkTheme: appProvider.darkTheme,
          themeMode: appProvider.flutterThemeMode,
          home: const AppStartupScreen(),
          routes: {'/question_screen': (context) => const QuestionScreen()},
        );
      },
    );
  }
}
