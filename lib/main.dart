import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'views/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QuickBiteApp());
}

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'QuickBite',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.softDark,
            themeMode: _getThemeMode(provider.themeMode),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode theme) {
    return switch (theme) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.softDark => ThemeMode.dark,
      AppThemeMode.midnight => ThemeMode.dark,
    };
  }
}
