import 'package:dmv_admin/firebase_options.dart';
import 'package:dmv_admin/ui/providers/practice_provider.dart';
import 'package:dmv_admin/ui/providers/auth_provider.dart';
import 'package:dmv_admin/ui/providers/settings_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/my_app.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  debugPrint("✅ Firebase успешно запущен!");

  final settProv = SettingsProvider();
  settProv.init();
  
  final authProv = AuthProvider();
  final pracProv = PracticeProvider(authProv);

  authProv.setProvider(pracProv);


  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProv),
            ChangeNotifierProvider.value(value: pracProv),
            ChangeNotifierProvider.value(value: settProv),
          ],
          child: const MyApp(),
      ));
}


