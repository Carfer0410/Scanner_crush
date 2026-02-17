import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';
class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  static LocaleService get instance => _instance;
  LocaleService._internal();

  static const String _localeKey = 'app_locale';
  Locale _currentLocale = const Locale('es'); // Default to Spanish

  Locale get currentLocale => _currentLocale;

  Future<void> initialize() async {
    LoggerService.debug('LocaleService initializing...', origin: 'LocaleService');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        _currentLocale = Locale(savedLocale);
        LoggerService.debug('Loaded saved locale: ${_currentLocale.languageCode}', origin: 'LocaleService');
      } else {
        // Try to detect system locale
        final systemLocale = PlatformDispatcher.instance.locale;
        if (systemLocale.languageCode == 'en' || systemLocale.languageCode == 'es') {
          _currentLocale = Locale(systemLocale.languageCode);
          LoggerService.debug('Using system locale: ${_currentLocale.languageCode}', origin: 'LocaleService');
          await _saveLocale(_currentLocale.languageCode);
        } else {
          LoggerService.debug('Using default locale: ${_currentLocale.languageCode}', origin: 'LocaleService');
          await _saveLocale(_currentLocale.languageCode);
        }
      }
    } catch (e) {
      LoggerService.error('Error initializing LocaleService: $e', origin: 'LocaleService');
      _currentLocale = const Locale('es');
    }
    
    LoggerService.info('LocaleService initialized - locale: ${_currentLocale.languageCode}', origin: 'LocaleService');
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != _currentLocale.languageCode) {
      LoggerService.debug('Changing locale from ${_currentLocale.languageCode} to $languageCode', origin: 'LocaleService');
      _currentLocale = Locale(languageCode);
      await _saveLocale(languageCode);
      notifyListeners();
      LoggerService.info('Locale changed to $languageCode', origin: 'LocaleService');
    }
  }

  Future<void> _saveLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      LoggerService.debug('Locale saved: $languageCode', origin: 'LocaleService');
    } catch (e) {
      LoggerService.error('Error saving locale: $e', origin: 'LocaleService');
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
