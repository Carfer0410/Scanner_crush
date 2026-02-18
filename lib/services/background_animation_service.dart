import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundAnimationService {
  BackgroundAnimationService._internal() {
    _load();
  }

  static final BackgroundAnimationService instance = BackgroundAnimationService._internal();

  static const String _kKey = 'enable_background_animation';

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      enabled.value = prefs.getBool(_kKey) ?? true;
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKey, value);
    } catch (_) {}
    enabled.value = value;
  }
}
