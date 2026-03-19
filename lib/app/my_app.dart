import 'package:dmv_admin/core/theme/app_theme.dart';
import 'package:dmv_admin/ui/providers/settings_provider.dart';
import 'package:dmv_admin/ui/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settProv = context.watch<SettingsProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkMode,
      themeMode: settProv.activeThem,
      home: Scaffold(
        body: MainScreen(),
      ),
    );
  }
}
