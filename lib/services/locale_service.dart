import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  static LocaleService get instance => _instance;
  LocaleService._internal();

  static const String _localeKey = 'app_locale';
  Locale _currentLocale = const Locale('es'); // Default to Spanish

  Locale get currentLocale => _currentLocale;

  Future<void> initialize() async {
    print('🌍 LocaleService initializing...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        _currentLocale = Locale(savedLocale);
        print('🌍 Loaded saved locale: ${_currentLocale.languageCode}');
      } else {
        // Try to detect system locale
        final systemLocale = PlatformDispatcher.instance.locale;
        if (systemLocale.languageCode == 'en' || systemLocale.languageCode == 'es') {
          _currentLocale = Locale(systemLocale.languageCode);
          print('🌍 Using system locale: ${_currentLocale.languageCode}');
          await _saveLocale(_currentLocale.languageCode);
        } else {
          print('🌍 Using default locale: ${_currentLocale.languageCode}');
          await _saveLocale(_currentLocale.languageCode);
        }
      }
    } catch (e) {
      print('❌ Error initializing LocaleService: $e');
      _currentLocale = const Locale('es');
    }
    
    print('🌍 LocaleService initialization complete - Current locale: ${_currentLocale.languageCode}');
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != _currentLocale.languageCode) {
      print('🌍 Changing locale from ${_currentLocale.languageCode} to $languageCode');
      _currentLocale = Locale(languageCode);
      await _saveLocale(languageCode);
      notifyListeners();
      print('🌍 Locale changed successfully to $languageCode');
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      print('🌍 Locale saved to preferences: $languageCode');
    } catch (e) {
      print('❌ Error saving locale: $e');
    }
  }

  bool get isSpanish => _currentLocale.languageCode == 'es';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }

  List<Locale> get supportedLocales => const [
    Locale('es'),
    Locale('en'),
  ];
}
