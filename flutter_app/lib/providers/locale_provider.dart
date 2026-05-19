import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  Future<void> init() async {
    final saved = await StorageService.loadLanguage();
    if (saved != null && saved.isNotEmpty) {
      _currentLocale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await StorageService.saveLanguage(languageCode);
    notifyListeners();
  }

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isHindi => _currentLocale.languageCode == 'hi';
  bool get isMarathi => _currentLocale.languageCode == 'mr';
  bool get isTamil => _currentLocale.languageCode == 'ta';
}
