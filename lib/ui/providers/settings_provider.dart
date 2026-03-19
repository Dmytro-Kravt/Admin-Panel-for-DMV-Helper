import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import '../../core/utils/utils.dart';

class SettingsProvider with ChangeNotifier {
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get activeThem => _themeMode;

  String _promtConfig = '';
  String _configLog = '';
  String get promtConfing => _promtConfig;
  String get configLog => _configLog;

  Future<void> init() async{
    unawaited(_getPracticePromtConfing());
  }

  void toggleCurrentTheme() {
    if (activeThem == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    }else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> _getPracticePromtConfing() async{
    try{
      await _config.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 0)
      ));

      await _config.fetchAndActivate();
      
      String newPromtConfig = _config.getString('prompt_AI_practice');

      _promtConfig = newPromtConfig;

      _configLog = 'AI Promt Configuration has gotten';
      printer('Promt Configuration', 'Has been goten');
      printer('New Promt Config', '\n$newPromtConfig');
    }catch(e){
      _configLog = 'Error into reciving AI Promt Configuration';
      printer('Error RemoteConfig E', e);
    }
  }
}