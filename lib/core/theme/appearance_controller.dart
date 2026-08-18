import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAppearance { light, dark, familyYear2026 }

class AppearanceController extends ChangeNotifier {
  AppearanceController();

  static final AppearanceController instance = AppearanceController();

  static const preferenceKey = 'app_appearance';

  AppAppearance _appearance = AppAppearance.light;

  AppAppearance get appearance => _appearance;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(preferenceKey);

    _appearance = AppAppearance.values.firstWhere(
      (appearance) => appearance.name == storedValue,
      orElse: () => AppAppearance.light,
    );
  }

  Future<void> setAppearance(AppAppearance appearance) async {
    if (_appearance == appearance) {
      return;
    }

    _appearance = appearance;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(preferenceKey, appearance.name);
  }
}
