import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  static const _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey);

    if (languageCode == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    _locale = locale;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, locale.languageCode);

    notifyListeners();
  }
}
