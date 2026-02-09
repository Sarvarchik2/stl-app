import 'package:flutter/material.dart';
import 'package:stl_app/core/app_theme.dart';
import 'package:stl_app/features/auth/presentation/pages/splash_screen.dart';
import 'package:stl_app/core/di/service_locator.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'package:stl_app/core/localization/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await initializeDateFormatting('ru', null);
  runApp(const STLApp());
}

class STLApp extends StatelessWidget {
  const STLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          key: ValueKey(lang),
          title: 'STL Logistics & Auto',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}
