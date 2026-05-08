import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/article.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/shell/shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  await Hive.openBox<Article>('articles');

  runApp(
    const ProviderScope(
      child: ReaderApp(),
    ),
  );
}

class ReaderApp extends StatelessWidget {
  const ReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ShellScreen(),
    );
  }
}